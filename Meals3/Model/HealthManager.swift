//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit
import CoreData
import AVFoundation

enum HealthManagerSynchronisationMode {
    case delete
    case store
    case update
}

/// Handles synchronization of meal data with HealthKit.
///
/// The following data are synched:
/// * energy,
/// * carbs,
/// * fat and
/// * protein.
///
/// The mealID of a meal is used as unique identifier. The mealID ist a string that represents the date when the meal was created.
///
/// This is a one way train from the Meals Application to Healthkit. Only changes in the Meal Application are synchronized to HealthKit. Changes in HealthKit are not synced back to the Meals Application.
///
/// HealthKit stores a meal as a so called food correlation which comprises the energy, carb, fat and protein quantities.
///
/// BEWARE: A deletion should be made before the meal is deleted in the Meals Application. Otherwhise the mealID is not yet existent any more and it is not possible any more to get a hold on the respecitve entry in HealthKit.
final class HealthManager {
    
    static let healthKitStore:HKHealthStore = HKHealthStore()
    
    /// Authorizes HealthKit (aka display the respective dialogue to the user).
    ///
    /// Authorization is requested for
    /// * dietary energy consumed
    /// * dietary carbohydrates
    /// * dietary protein
    /// * dietery fat total
    /// - Parameter completion: completion handler
    class func authorizeHealthKit(_ completion: ((_ success: Bool, _ error: NSError?) -> Void)!) {
        
        // 1. and 2. Set the types you want to share and read from HK Store
        let healthKitSampleTypesToShare = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed),
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates),
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein),
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)
            ]
            .compactMap{$0 as HKSampleType?}
        
        let healthKitObjectTypesToRead = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed),
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates),
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein),
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)
            ]
            .compactMap{$0 as HKObjectType?}
        
        let healthKitTypesToShare: Set? = Set<HKSampleType>(healthKitSampleTypesToShare)
        let healthKitTypesToRead: Set?  = Set<HKObjectType>(healthKitObjectTypesToRead)
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if completion != nil {
                completion(false , error)
            }
            return
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorization(toShare: healthKitTypesToShare, read: healthKitTypesToRead) { (success, error) -> Void in
            if completion != nil {
                let hugo = error as NSError?
                completion(success, hugo)
            }
        }
    }
    
    
    /// Synchronizes changes to a meal with HealthKit.
    ///
    /// Of the meal data, the following attributes are stored in HealthKit:
    /// * energy    -> dieatary energy consumption in kcal
    /// * carbs     -> ditery carbohytrates in g
    /// * fat       -> dietary fat total in g
    /// * protein   -> dietary protein
    ///
    /// The following synchronization modes are possible:
    /// * .store -> Store a new entry which is not yet in HealthKit
    /// * .delete -> Delete an entry from HealthKit
    /// * .update -> Update an existing entry in HealthKit
    ///
    /// BEWARE: A deletion should be made before the meal is deleted in the Meals Application. Otherwhise the mealID is not yet existent any more and it is not possible any more to get a hold on the respecitve entry in HealthKit.
    ///
    /// HealthKit does not allow to update the quantities of a food correlation, thus, if an update is requested, the already stored food correlation
    /// will be deleted and afterwards a new food correlation for the meal will be saved in HealthKit.
    /// - Parameters:
    ///   - meal: the meal which to be synchronized with HealthKit
    ///   - synchronisationMode: .store, .delete or .update
    class func synchronize(_ meal: Meal, withSynchronisationMode synchronisationMode: HealthManagerSynchronisationMode) {

        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this Device")
            // let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            return
        }
        if meal.mealID == nil {
            meal.mealID = ISO8601DateFormatter().string(from: meal.dateOfCreation ?? Date()) // Older meals might have nil, since mealID was introduced in Dec. 2021
        }
        guard let mealID = meal.mealID else { return }

        switch synchronisationMode {
        case .store:
            Task { await storeFoodCorrelationForMeal(meal) }
        case .delete:
            Task { await deleteFoodCorrelationForMealID(mealID)  }
        case .update:
            Task {
                await deleteFoodCorrelationForMealID(mealID)
                await storeFoodCorrelationForMeal(meal)
            }
        }
        
        print("Finished sychronizing at Date ---- \(Date()) -----")
    }
    
    class func synchronizeMeals(_ meals: [Meal]?) {

        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this Device")
            // let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            return
        }
        
        if let meals = meals {
                        
            Task {
                print("#---------------------------------------------------")
                print("Start Date: \(Date())")
                print("We have \(meals.count) meals to store to HealthKit")
                
                for meal in Array(meals.reversed()) { // start with oldest entries.
                    if meal.mealID == nil, meal.dateOfCreation != nil {
                        meal.mealID = ISO8601DateFormatter().string(from: meal.dateOfCreation!)
                    } else if meal.dateOfCreation == nil {
                        print("Skipping this meal, since it has no mealID and no dateOfCreation.")
                        continue
                    }
                    
                    await deleteFoodCorrelationForMealID(meal.mealID!)
                    await storeFoodCorrelationForMeal(meal)
                }
                
                print("End Date: \(Date())")
                print("#===================================================")
            }
        }
    }

    
    /// Stores a meal as food correlation in HealthKit.
    ///
    /// The food correlation has the mealID as metadate which is used as unique identifier for the meal for later upadate or deletion.
    ///
    /// - Parameter meal: the meal to be stored as food correlation in HealthKit
    private class func storeFoodCorrelationForMeal(_ meal: Meal) async {
        
        // 1. Create a food correlation (aka meal representation) from the meal data
        guard let foodCorrelation = createFoodCorrelationForMeal(meal) else {
            return
        }
        // 2. Save the food correlation in the HealthKit store
        do {
            try await healthKitStore.save(foodCorrelation)
            print("Saved the food correlation for the meal with mealID (yes, a date is used as mealID): \(meal.mealID!)  successfully in HealthKit store!")
        } catch {
            print("Error saving food correlation for the meal with mealID (yes, a date is used as mealID): \(meal.mealID!) in HealthKit store: \(error.localizedDescription)")
        }
    }
    
    
    /// Creates a HealhtKit food correlation for the respective meal.
    ///
    /// The food correlation is created, but not yet stored in HealthKit.
    /// The mealID of the meal is put into the metadata and used as identifier for the entry and can later be used to delete or update the entry.
    ///
    /// - Parameter meal: the meal to create the food correlation from
    /// - Returns: The food correlation, later to be stored in HealtKit
    private class func createFoodCorrelationForMeal(_ meal: Meal) -> HKCorrelation? {
        print("About to save the meal with mealID (yes, a date is used as mealID): \(meal.mealID!) to HealthKit")
        let managedObjectContext = meal.managedObjectContext
        let mealMetaData = ["comment": meal.comment ?? "",
                            "mealID": meal.mealID]

        // match health kit quantity identifiers with nutrients of this application
        let identifiers = [("totalEnergyCals", HKQuantityTypeIdentifier.dietaryEnergyConsumed),
                           ("totalCarb", HKQuantityTypeIdentifier.dietaryCarbohydrates),
                           ("totalProtein", HKQuantityTypeIdentifier.dietaryProtein),
                           ("totalFat", HKQuantityTypeIdentifier.dietaryFatTotal)]
        
        // create set of health kit quantity samples
        var quantitySamples = Set<HKQuantitySample>()
        for identifierTuple in identifiers {
            if let type = HKQuantityType.quantityType(forIdentifier: identifierTuple.1),
                let nutrient = Nutrient.nutrientForKey(identifierTuple.0, inManagedObjectContext: managedObjectContext!) {
                let quantity = HKQuantity(unit: nutrient.hkUnit, doubleValue: meal.doubleForNutrient(nutrient) ?? 0.0)
                quantitySamples.insert(HKQuantitySample(type: type, quantity: quantity, start: meal.dateOfCreation! as Date, end: meal.dateOfCreation! as Date, metadata: mealMetaData as [String : Any]))
            }
        }
        
        // Combine nutritional data (the quantity samples, aka carbs, fat, protein and energy) into a food correlation (aka meal in my terms)
        if let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food) {
            return HKCorrelation(type: correlationType, start: meal.dateOfCreation! as Date, end: meal.dateOfCreation! as Date, objects: quantitySamples, metadata: mealMetaData as [String : Any])
        }
        return nil
    }
    
    
    /// Gets the food correlation for a meal from HealthKit.
    ///
    /// Defines the query and executes it.
    /// The food correlation is identified via the mealID which is part of the metadata.
    /// There should only be one food correlation for a meal. If there where more (for whatever reason) they will be returned, too.
    /// - Parameter meal: the meal for which the food correlation is stored in HealthKit
    /// - Returns: food correlations in HealthKit for the meal
    private class func getFoodCorrelationsForMealID(_ mealID: String) async -> [HKCorrelation]? {
        print("About to query the food correlation for the meal with mealID (yes, a date is used as mealID): \(mealID)  successfully in HealthKit store!")

        let predicate = HKQuery.predicateForObjects(withMetadataKey: "mealID", allowedValues: [mealID])
        
        guard let sampleType = HKSampleType.correlationType(forIdentifier: .food)  else { return nil }

        // Trick with Contiunation, see https://brunoscheufler.com/blog/2021-11-07-accessing-workouts-with-healthkit-and-swift
        let foodCorrelations = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKCorrelation], Error>) in

            healthKitStore.execute(
                HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil) { (sampleQuery, results, error ) in
                    
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    // Although there should only be one correlation (food), the query returns an array of correlations that have to be handled.
                    // (And maybe due to some error, there are more than one foods stored and should be deleted, so better handle the array)
                    guard let foodCorrelations = results as? [HKCorrelation] else {
                        print ("no food correlations")
                        fatalError("*** Invalid State: This can only fail if there was an error. ***")
                    }
                    print("1. Successfully queried the food correlation for the meal with mealID (yes, a date is used as mealID): \(mealID)  successfully in HealthKit store!")
                    continuation.resume(returning: foodCorrelations)
                }
            )
        }
        print("2. Successfully queried the food correlation for the meal with mealID (yes, a date is used as mealID): \(mealID)  successfully in HealthKit store!")
        return foodCorrelations
    }
    

    
    /// Deletes the food correlation stored in HealthKit for a meal.
    ///
    /// - Parameters:
    ///   - mealID: the mealID of the meal for which the food correlation shall be deleted
    private class func deleteFoodCorrelationForMealID(_ mealID: String) async {
        
        print("About to delete the meal with mealID (yes, a date is used as mealID): \(mealID) from HealthKit")

        do {
            let foodCorrelations = await getFoodCorrelationsForMealID(mealID) // get the food correlation from HealthKit
            print("after getFoodCorrelationsForMeal")
            // delete the food correlation from HealthKit
            if let foodCorrelations = foodCorrelations {
                for foodCorrelation in foodCorrelations {
                    // delete the food's objects (i.e. dietaryEnergy, carbs, fat and protein)
                    print("before delete objects")
                    try await healthKitStore.delete(Array(foodCorrelation.objects)) // delete carb, fat, protein, dietaryEngergy for the food correlation (aka meal in my terms)
                    print("After delete objects")
                    try await healthKitStore.delete(foodCorrelation)                // delete the food correlation (aka meal in my terms) itself
                    print("After delete food correlations")
                }
            }
            print("Deleted the food correlation for the meal with mealID (yes, a date is used as mealID): \(mealID)  successfully in HealthKit store!")

        } catch {
            print("An error occured trying to delete or update the meal with mealID (yes, a date is used as mealID): \(mealID)  successfully in HealthKit store!")
        }
    }
    
}
