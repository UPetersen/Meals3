//
//  FoodExtension.swift
//  bLS
//
//  Created by Uwe Petersen on 25.10.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData
import HealthKit

extension Food {
    
    override public func awakeFromInsert() {
        
        // Set date automatically when object ist created
        super.awakeFromInsert()
        self.dateOfCreation = Date() as NSDate as Date
        self.dateOfLastModification = Date() as NSDate as Date
    }
    
    class func newFood(inManagedObjectContext context: NSManagedObjectContext) -> Food {
        let newFood = Food(context: context)
        newFood.name = "Neues Lebensmittel"
        return newFood
    }
    
    class func fromFood(_ foodToCopyFrom:Food, inManagedObjectContext context: NSManagedObjectContext) -> Food {
        
        let newFood = Food(context: context)
        
        // Copy all attributes
        for key in foodToCopyFrom.entity.attributesByName.keys {
            newFood.setValue(foodToCopyFrom.value(forKey: key ), forKey: key )
        }
        
        // Copy some relationships
        newFood.detail = foodToCopyFrom.detail
        newFood.favoriteListItem = foodToCopyFrom.favoriteListItem
        newFood.group = foodToCopyFrom.group
        newFood.subGroup = foodToCopyFrom.subGroup
        newFood.preparation = foodToCopyFrom.preparation
        newFood.referenceWeight = foodToCopyFrom.referenceWeight
        newFood.servingSizes = foodToCopyFrom.servingSizes
        
        // Modify Dates and name
        newFood.name = "Kopie von \(String(describing: newFood.name))"
        newFood.dateOfCreation = Date() as NSDate as Date
        newFood.dateOfLastModification = Date() as NSDate as Date
        
        return newFood
    }
    
    class func fromRecipe(_ recipe: Recipe, inManagedObjectContext context: NSManagedObjectContext) -> Food {
        
        let newFood = Food(context: context)
        
        let recipeAmount = recipe.amount?.doubleValue ?? 0.0
        
        //  Set all nutrient values per 100 grams
        if let nutrients = Nutrient.fetchAllNutrients(managedObjectContext: context) {
            for nutrient in nutrients {
                if let value = recipe.doubleForNutrient(nutrient) {
                    let valuePer100g = value / recipeAmount * 100.0
                    newFood.setValue(valuePer100g, forKey: nutrient.key!)
                }
            }
        }
        
        // set some relationships
//        newFood.detail = foodToCopyFrom.detail
//        newFood.favoriteListItem = foodToCopyFrom.favoriteListItem
//        newFood.group = foodToCopyFrom.group
//        newFood.subGroup = foodToCopyFrom.subGroup
//        newFood.preparation = foodToCopyFrom.preparation
//        newFood.referenceWeight = foodToCopyFrom.referenceWeight
//        newFood.servingSizes = foodToCopyFrom.servingSizes
        
        // Modify Dates and name
        newFood.name = "Rezept vom " + "\(String(describing: recipe.dateOfCreation))"
        newFood.dateOfCreation = recipe.dateOfCreation
        newFood.dateOfLastModification = recipe.dateOfLastModification
        newFood.recipe = recipe
        
        return newFood
    }
    
    func updateNutrients(managedObjectContext context: NSManagedObjectContext) {
        if let recipe = self.recipe {
            let recipeAmount = recipe.amountOfAllIngredients
            recipe.amount = NSNumber(value: recipeAmount) // Reset all manual changes if the nutrients are updated
            if let nutrients = Nutrient.fetchAllNutrients(managedObjectContext: context) {
                for nutrient in nutrients {
                    if let value = recipe.doubleForNutrient(nutrient) {
                        let valuePer100g = value / recipeAmount * 100.0
                        self.setValue(valuePer100g, forKey: nutrient.key!)
                    }
                }
            }
            self.dateOfLastModification = Date()
        }
    }
    
    
    class func fetchAllFoods(managedObjectContext context: NSManagedObjectContext) -> [Food]? {

        let request: NSFetchRequest<Food> = Food.fetchRequest()

        do {
            let foods = try context.fetch(request)
            return foods
        } catch {
            print("Error fetching foods: \(error)")
        }
        return nil
    }
    
    class func foodForNameContainingString(_ string: String, inMangedObjectContext context: NSManagedObjectContext) -> Food? {

        // Returns the very first of the foods with a name that contains the given input string
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[c] %@", string)
        
        // Return first object in the list of foods, or nil, if no food ist there with this string
        do {
            let foods = try context.fetch(request)
            return foods.first
        } catch {
            print("Error fetching foods: \(error)")
        }
        return nil
    }
    
    
    func addToFavorites(managedObjectContext context: NSManagedObjectContext) { // Adds the food to the list of favorite foods (if not already on that list)
        
        if self.favoriteListItem?.food === self {
            // Food is already a favorite, nothing has to be done
            print("Food with name \(String(describing: name)) and favorite status \(String(describing: self.favoriteListItem)) is already a favorite")
            
        } else {
            // Food is not yet a favorite and must be added as a favorite
            print("Food with name \(String(describing: name)) is not yet a favorite and will be added as a favorite")
            let favorite = Favorite(context: context)
            favorite.food = self
        }
    }

    func isMealIngredient() -> Bool {
        if self.mealIngredients != nil && self.mealIngredients!.count > 0 {
            return true
        }
        return false
    }
    
    func isRecipeIngredient() -> Bool {
        if self.recipeIngredients != nil && self.recipeIngredients!.count > 0 {
            return true
        }
        return false
    }
    
    func isMealAndRecipeIngredient() -> Bool {
        return self.isMealIngredient() && self.isRecipeIngredient()
    }
    
    /// Return the value as a String in the unit specified by hkDispUnit in nutrients, e.g. "12.3 µg"
    /// If something fails, either nil or an empty unit string (e.g. "g") is returned, depending on showUnit
    func dispStringForNutrient(_ nutrient: Nutrient, formatter: NumberFormatter, showUnit: Bool = true) -> String? {
        return nutrient.dispStringForValue(self.doubleForKey(nutrient.key!), formatter: formatter, showUnit: showUnit)
    }
    
    /// Return the value as a String in the unit specified by hkDispUnit in nutrients, e.g. "12.3 µg"
    /// If something fails, either nil or an empty unit string (e.g. "g") is returned, depending on showUnit
    func dispStringForNutrientWithKey(_ key: String, formatter: NumberFormatter, showUnit: Bool = true) -> String? {
        if let managedObjectContext = self.managedObjectContext, let nutrient = Nutrient.nutrientForKey(key, inManagedObjectContext: managedObjectContext) {
            return nutrient.dispStringForValue(self.doubleForKey(nutrient.key!), formatter: formatter, showUnit: showUnit) ?? nil
        }
        return nil
    }
    
    func nutrientStringForFood(formatter: NumberFormatter) -> String {
        if let context = self.managedObjectContext {
            let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: self.doubleForKey("totalEnergyCals"), formatter: formatter, inManagedObjectContext: context) ?? ""
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: self.doubleForKey("totalCarb"),    formatter: formatter, inManagedObjectContext: context) ?? ""
            let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: self.doubleForKey("totalProtein"), formatter: formatter, inManagedObjectContext: context) ?? ""
            let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: self.doubleForKey("totalFat"),     formatter: formatter, inManagedObjectContext: context) ?? ""
            let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: self.doubleForKey("carbFructose"), formatter: formatter, inManagedObjectContext: context) ?? ""
            let carbGlucose   = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: self.doubleForKey("carbGlucose"),  formatter: formatter, inManagedObjectContext: context) ?? ""
            return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " P, " + totalFat + " F, " + carbFructose + " Fr., " + carbGlucose + " Gl."
        }
        return "no data"
    }

    
    
    // MARK: - transient properties

    // TO MAKE THIS WORK: uncommented the property (@unmanaged) in the file generated by core data. Now this property is taken from here instead of the database.
    // Needed for table view with list of foods where section indexes are displayed (e.g. the favorites table)
//    func uppercaseFirstLetterOfName() -> String {
//        self.willAccessValue(forKey: "uppercaseFirstLetterOfName")
//        let aString: String = self.name?.uppercased() ?? " "
//        self.didAccessValue(forKey: "uppercaseFirstLetterOfName")
//        return String(aString[...aString.startIndex]) // 2017-10-08: Swift 4, hopefully this works fine (and supports at least UTF-16)
//    }
    @objc dynamic var  uppercaseFirstLetterOfName: String {
        self.willAccessValue(forKey: "uppercaseFirstLetterOfName")
        let aString: String = self.name?.uppercased() ?? " "
        self.didAccessValue(forKey: "uppercaseFirstLetterOfName")
        return String(aString[...aString.startIndex]) // 2017-10-08: Swift 4, hopefully this works fine (and supports at least UTF-16)
    }


    func deletionConfirmation() -> String {
        if self.isMealAndRecipeIngredient() {
            let uniqueMeals = Set(self.mealIngredients!.compactMap{ ($0 as AnyObject).meal })
            let uniqueRecipes = Set (self.recipeIngredients!.compactMap{ ($0 as AnyObject).recipe })
            return "Dieses Lebensmittel wird \(self.mealIngredients!.count) mal in insgesamt \(uniqueMeals.count) Mahlzeit(en) verwendet und wird aus diesen gelöscht.\n\nDieses Lebensmittel wird außerdem \(self.recipeIngredients!.count) mal in insgesamt \(uniqueRecipes.count) Rezept(en) verwendet und wird auch aus diesen gelöscht. "
        } else if self.isMealIngredient() {
            let uniqueMeals = Set(self.mealIngredients!.compactMap{ ($0 as AnyObject).meal })
            return "Dieses Lebensmittel wird \(self.mealIngredients!.count) mal in insgesamt \(uniqueMeals.count) Mahlzeit(en) verwendet und wird diesen gelöscht."
        } else if self.isRecipeIngredient() {
            let uniqueRecipes = Set (self.recipeIngredients!.compactMap{ ($0 as AnyObject).recipe })
            return "Dieses Lebensmittel wird \(self.recipeIngredients!.count) mal in insgesamt \(uniqueRecipes.count) Rezept(en) verwendet und wird diesen gelöscht."
        }
        return "Dieses Lebensmitttel wird bisher in keiner Mahlzeit und keinem Rezept genutzt."
    }

    
}


extension Food: Identifiable {
    
}



extension Food: HasNutrients {
    
    // To comply with HasNutriens protocol. Amount of a Food is 100 g, cause this is everything in this database refers to
    var amount: NSNumber? {
        return NSNumber(value: 100.0) // Changed type to NSNumber? with iOS 11
    }

    public func doubleForKey(_ key: String) -> Double? {
        return (self.value(forKey: key) as? NSNumber)?.doubleValue ?? nil
    }
}
