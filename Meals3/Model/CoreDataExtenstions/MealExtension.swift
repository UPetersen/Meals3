//
//  MealExtension.swift
//  bLS
//
//  Created by Uwe Petersen on 21.12.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData
import HealthKit

var dateOfCreationAsString_: String? = nil

//let RFC3339DateFormatter = DateFormatter()
//RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
//RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)


extension Meal {
    
    public override func awakeFromInsert() {
        
        // Set date automatically when object ist created
        super.awakeFromInsert()
        dateOfCreation = Date() as NSDate as Date
        dateOfLastModification = Date() as NSDate as Date
        mealID = ISO8601DateFormatter().string(from: dateOfCreation ?? Date())
    }
    
//    override public func didChange(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, forKey key: String) {
//        print("Meal did change the following: ")
//        print("\(changeKind)")
//        print("\(indexes)")
//        print("\(key)")
//    }
    
    
    func doubleForNutrient(_ nutrient: Nutrient) -> Double? {
        return doubleForKey(nutrient.key!)
    }
    
    func hasFood(_ food: Food) -> Bool {
        for mealIngredient in ingredients?.allObjects as! [MealIngredient] {
            if mealIngredient.food == food {
                return true
            }
        }
        return false
    }
    
    
    // MARK: - transient property stuff for section headers (must be strings, take from transient property which is calculated from persistent date property)

    // TO MAKE THIS WORK: uncommented the property (@unmanaged) in the file generated by core data. Now this property is taken from here instead of the database.
//    @objc dynamic var dateOfCreationAsString: String {
//        get {
//            // Create the section identifier on demand. This is also a transient property in the core data database. Although, this seems to work without the transient property, too
//            self.willAccessValue(forKey: "dateOfCreationAsString")
//            
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss'"
//            //        formatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
//            let stringToReturn = formatter.string(from: self.dateOfCreation! as Date)
//            
//            self.didAccessValue(forKey: "dateOfCreationAsString")
//            
//            return stringToReturn
//        }
//    }
    

    /// Fetches all meals from the core data database.
    class func fetchAllMeals(managedObjectContext context: NSManagedObjectContext) -> [Meal]? {
        
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateOfCreation", ascending: false)]

        do {
            let meals = try context.fetch(request)
            return meals
        } catch {
            print("Error fetching all meals: \(error)")
        }
        return nil
    }
    
    
    /// Fetches the newest meal from the core data database.
    // TODO: get newes meal directly and not all meals and then the newest one. We meanwhile have over 13800 meals as of 2021-12-06
    private class func fetchNewestMeal(managedObjectContext context: NSManagedObjectContext) -> Meal? {

        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "dateOfCreation", ascending: false)]
        
        do {
            let meals = try context.fetch(request)
//            print("Wir haben inzwischen \(meals.count) Mahlzeiten.")
            print("Letztes")
//            print(meals.last?.description)
            print("Letztes")
            return meals.first
        } catch {
            print("Error fetching newest meal: \(error)")
        }
        return nil
    }
    
    /// Returns the newest meal or creates a new meal if non yet exists.
    /// - Parameter context: managed object context
    class func newestMeal(managedObjectContext context: NSManagedObjectContext) -> Meal {
        let newestMeal = Meal.fetchNewestMeal(managedObjectContext: context)
        if let newestMeal = newestMeal {
            return newestMeal
        } else {
            return Meal(context: context)
        }
    }
    

    

    /// Creates a new meal by from the given meal.The new meal will have the same meal ingredients and that is it.
    /// Everything else will be as with a new meal. Since meal ingredients are unique to a meal, the have to be
    /// created newly from the ones of the given meal.
    class func fromMeal(_ meal: Meal, inManagedObjectContext context: NSManagedObjectContext) -> Meal? {
        let newMeal = Meal(context: context)
        // copy meal ingredients (a meal ingredient can have only one meal, thus new meal ingredients have to be created)
        if let mealIngredients = meal.ingredients?.allObjects as? [MealIngredient] {
            for mealingredient in mealIngredients {
                let newMealIngredient = MealIngredient(context: context)
                newMealIngredient.food = mealingredient.food
                newMealIngredient.amount = mealingredient.amount
                newMealIngredient.meal = newMeal
            }
        }
        return newMeal
    }
    
    
    public override var description: String {
        var string = String("Meal from \(String(describing: dateOfCreation)), last change: \(String(describing: dateOfLastModification))\n")
        string.append(String("   with comment: \(String(describing: comment)))\n"))
        string.append(String("   and \(String(describing: ingredients?.count ?? 0)) ingredients.\n"))
        if let ingredients = ingredients, let mealIngredients = ingredients.allObjects as? [MealIngredient] {
            for mealIngredient in mealIngredients {
                string.append("\(mealIngredient.description)\n")
            }
        }
        return string
    }
}


extension Meal {
    /// Returns the fat protein units (FPU or FPE in German) for the meal.
    var fpu: Double? {
        if let protein = doubleForKey("totalProtein"), let fat = doubleForKey("totalFat") {
            return (4.0 * protein + 9.0 * fat) / 100.0 / 1000.0
        }
        return nil
    }

    var fpuFalse: Double? {
        if let protein = doubleForKey("totalProtein"), let fat = doubleForKey("totalFat") {
            return (9.0 * protein + 4.0 * fat) / 100.0 / 1000.0
        }
        return nil
    }
}

extension Meal: HasNutrients {
    
        /// Overall amount of all meal ingredients in gram
        var amount: NSNumber? {
            let aDouble:Double = ingredients?.allObjects
                .filter{$0 is MealIngredient}
                .map {$0 as! MealIngredient}
                .map {$0.amount!.doubleValue}
                .reduce(0.0, +) ?? 0
            return NSNumber(value: aDouble)
        }

    
    
        // FIXME: hier mit weak und unowned experimentieren, für die $0
        /// sum of the content of one nutrient (e.g. "totalCarb") in a meal. Thus one has to sum over all (meal) ingredients
        /// Example: (sum [totalCarb content of each ingredient] / 100)
        func doubleForKey(_ key: String) -> Double? {

            guard let ingredients = ingredients else {return nil}
            let quantities = ingredients.compactMap{$0 as? MealIngredient}
            .filter {$0.food?.value(forKeyPath: key) is NSNumber}             // valueForKeyPath returns AnyObject, thus check if it is of type NSNumber, and use only these
            .map   {($0.food?.value(forKeyPath: key) as! NSNumber).doubleValue / 100.0 * ($0.amount?.doubleValue)!} // Convert to NSNumber and then Double and multiply with amount of this ingredient
            
            // sum up the values of all meal ingredients or return nil if no ingredients values where availabel (i.e. all foods had no entry for this nutrient)
            if quantities.isEmpty {
                return nil
            } else {
                return quantities.reduce(0.0, +)
            }
        }
}

extension Meal: IngredientCollection {
    func addIngredient(food: Food, amount: NSNumber, managedObjectContext: NSManagedObjectContext) {

        let mealIngredient = MealIngredient(context: managedObjectContext)
        mealIngredient.food = food
        mealIngredient.amount = amount
        addToIngredients(mealIngredient)
        dateOfLastModification = Date()
        try? managedObjectContext.save()
        
//            // Save and sync to HealthKit
//             saveContextAndsyncToHealthKit(self)
    }
}
