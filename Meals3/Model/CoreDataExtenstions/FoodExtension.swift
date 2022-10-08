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
        dateOfCreation = Date() as NSDate as Date
        dateOfLastModification = Date() as NSDate as Date
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // Modify Dates and name
        newFood.name = "Rezept vom " + "\(dateFormatter.string(from: Date()))"
        newFood.dateOfCreation = recipe.dateOfCreation
        newFood.dateOfLastModification = recipe.dateOfLastModification
        newFood.recipe = recipe
        
        return newFood
    }
    
//    func updateNutrients(managedObjectContext context: NSManagedObjectContext) {
//        if let recipe = self.recipe {
//            let recipeAmount = recipe.amountOfAllIngredients
//            recipe.amount = NSNumber(value: recipeAmount) // Reset all manual changes if the nutrients are updated
//            if let nutrients = Nutrient.fetchAllNutrients(managedObjectContext: context) {
//                for nutrient in nutrients {
//                    if let value = recipe.doubleForNutrient(nutrient) {
//                        let valuePer100g = value / recipeAmount * 100.0
//                        self.setValue(valuePer100g, forKey: nutrient.key!)
//                    }
//                }
//            }
//            self.dateOfLastModification = Date()
//        }
//    }
    
    private func updateNutrients(amount: Double, managedObjectContext context: NSManagedObjectContext) {
        if let recipe = recipe {
            recipe.amount = NSNumber(value: amount)
            if let nutrients = Nutrient.fetchAllNutrients(managedObjectContext: context) {
                for nutrient in nutrients {
                    if let value = recipe.doubleForNutrient(nutrient) {
                        let valuePer100g = value / amount * 100.0
                        setValue(valuePer100g, forKey: nutrient.key!)
                    }
                }
            }
        }
    }
    
    func updateNutrients(amount: RecipeAmount, managedObjectContext context: NSManagedObjectContext) {
        if let recipe = recipe {
            switch amount {
            case .sumOfAmountsOfRecipeIngredients: // use sum of ingredient amounts as overall amount (no weight loss  due to heating)
                updateNutrients(amount: recipe.amountOfAllIngredients, managedObjectContext: context)
            case .asInputByUser(let amount):
                if let amount = amount, amount >= 0.1 {
                    updateNutrients(amount: amount, managedObjectContext: context) // Reset all manual changes if non-valid value
                } else {
                    updateNutrients(amount: recipe.amountOfAllIngredients, managedObjectContext: context)
                }
            }
            dateOfLastModification = Date()
        }
    }
    

//    class func fetchAllFoods(managedObjectContext context: NSManagedObjectContext) -> [Food]? {
//
//        let request: NSFetchRequest<Food> = Food.fetchRequest()
//
//        do {
//            let foods = try context.fetch(request)
//            return foods
//        } catch {
//            print("Error fetching foods: \(error)")
//        }
//        return nil
//    }
    
//    class func foodForNameContainingString(_ string: String, inMangedObjectContext context: NSManagedObjectContext) -> Food? {
//
//        // Returns the very first of the foods with a name that contains the given input string
//        let request: NSFetchRequest<Food> = Food.fetchRequest()
//        request.predicate = NSPredicate(format: "name CONTAINS[c] %@", string)
//
//        // Return first object in the list of foods, or nil, if no food ist there with this string
//        do {
//            let foods = try context.fetch(request)
//            return foods.first
//        } catch {
//            print("Error fetching foods: \(error)")
//        }
//        return nil
//    }
//
    
    func addToFavorites(managedObjectContext context: NSManagedObjectContext) { // Adds the food to the list of favorite foods (if not already on that list)
        
        if favoriteListItem?.food === self {
            // Food is already a favorite, nothing has to be done
            print("Food with name \(String(describing: name)) and favorite status \(String(describing: favoriteListItem)) is already a favorite")
            
        } else {
            // Food is not yet a favorite and must be added as a favorite
            print("Food with name \(String(describing: name)) is not yet a favorite and will be added as a favorite")
            let favorite = Favorite(context: context)
            favorite.food = self
        }
    }

    func isMealIngredient() -> Bool {
        if mealIngredients != nil && mealIngredients!.count > 0 {
            return true
        }
        return false
    }
    
    func isRecipeIngredient() -> Bool {
        if recipeIngredients != nil && recipeIngredients!.count > 0 {
            return true
        }
        return false
    }
    
    func isMealAndRecipeIngredient() -> Bool {
        return isMealIngredient() && isRecipeIngredient()
    }
    
    /// Return the value as a String in the unit specified by hkDispUnit in nutrients, e.g. "12.3 µg"
    /// If something fails, either nil or an empty unit string (e.g. "g") is returned, depending on showUnit
    func dispStringForNutrient(_ nutrient: Nutrient, formatter: NumberFormatter, showUnit: Bool = true) -> String? {
        return nutrient.dispStringForValue(doubleForKey(nutrient.key!), formatter: formatter, showUnit: showUnit)
    }
    
    /// Return the value as a String in the unit specified by hkDispUnit in nutrients, e.g. "12.3 µg"
    /// If something fails, either nil or an empty unit string (e.g. "g") is returned, depending on showUnit
    func dispStringForNutrientWithKey(_ key: String, formatter: NumberFormatter, showUnit: Bool = true) -> String? {
        if let managedObjectContext = managedObjectContext, let nutrient = Nutrient.nutrientForKey(key, inManagedObjectContext: managedObjectContext) {
            return nutrient.dispStringForValue(doubleForKey(nutrient.key!), formatter: formatter, showUnit: showUnit) ?? nil
        }
        return nil
    }
    
    func nutrientStringForFood(formatter: NumberFormatter) -> String {
        if let context = managedObjectContext {
            let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: doubleForKey("totalEnergyCals"), formatter: formatter, inManagedObjectContext: context) ?? ""
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: doubleForKey("totalCarb"),    formatter: formatter, inManagedObjectContext: context) ?? ""
            let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: doubleForKey("totalProtein"), formatter: formatter, inManagedObjectContext: context) ?? ""
            let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: doubleForKey("totalFat"),     formatter: formatter, inManagedObjectContext: context) ?? ""
            let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: doubleForKey("carbFructose"), formatter: formatter, inManagedObjectContext: context) ?? ""
            let carbGlucose   = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: doubleForKey("carbGlucose"),  formatter: formatter, inManagedObjectContext: context) ?? ""
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
        willAccessValue(forKey: "uppercaseFirstLetterOfName")
        let aString: String = name?.uppercased() ?? " "
        didAccessValue(forKey: "uppercaseFirstLetterOfName")
        return String(aString[...aString.startIndex]) // 2017-10-08: Swift 4, hopefully this works fine (and supports at least UTF-16)
    }


    func deletionConfirmation() -> String {
        if isMealAndRecipeIngredient() {
            let uniqueMeals = Set(mealIngredients!.compactMap{ ($0 as AnyObject).meal })
            let uniqueRecipes = Set (recipeIngredients!.compactMap{ ($0 as AnyObject).recipe })
            return "Dieses Lebensmittel wird \(mealIngredients!.count) mal in insgesamt \(uniqueMeals.count) Mahlzeit(en) verwendet und wird aus diesen gelöscht.\n\nDieses Lebensmittel wird außerdem \(recipeIngredients!.count) mal in insgesamt \(uniqueRecipes.count) Rezept(en) verwendet und wird auch aus diesen gelöscht. "
        } else if isMealIngredient() {
            let uniqueMeals = Set(mealIngredients!.compactMap{ ($0 as AnyObject).meal })
            return "Dieses Lebensmittel wird \(mealIngredients!.count) mal in insgesamt \(uniqueMeals.count) Mahlzeit(en) verwendet und wird diesen gelöscht."
        } else if isRecipeIngredient() {
            let uniqueRecipes = Set (recipeIngredients!.compactMap{ ($0 as AnyObject).recipe })
            return "Dieses Lebensmittel wird \(recipeIngredients!.count) mal in insgesamt \(uniqueRecipes.count) Rezept(en) verwendet und wird diesen gelöscht."
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
        return (value(forKey: key) as? NSNumber)?.doubleValue ?? nil
    }
}


extension Food {

     func updateFromOffProduct(product: OFFProduct, inManagedObjectContext context: NSManagedObjectContext) {
        
        key = product.code
        name = product.name

        totalEnergyCals              = product.energyCals   != nil ? NSNumber(value: product.energyCals!) : nil
        
        totalCarb                    = product.carbs        != nil ? NSNumber(value: product.carbs! * 1000.0) : nil        // g -> mg
        totalFat                     = product.fat          != nil ? NSNumber(value: product.fat! * 1000.0) : nil          // g -> mg
        totalProtein                 = product.protein      != nil ? NSNumber(value: product.protein! * 1000.0) : nil      // g -> mg
        totalDietaryFiber            = product.fiber        != nil ? NSNumber(value: product.fiber! * 1000.0) : nil        // g -> mg
        totalSalt                    = product.salt         != nil ? NSNumber(value: product.salt! * 1000.0) : nil         // g -> mg
        carbSugar                    = product.sugar        != nil ? NSNumber(value: product.sugar! * 1000.0) : nil        // g -> mg
        fattyAcidSaturatedFattyAcids = product.saturatedFat != nil ? NSNumber(value: product.saturatedFat! * 1000.0) : nil // g -> mg
        
        dateOfCreation = product.created ?? Date(timeIntervalSince1970: 0)
        dateOfLastModification = product.lastModified ?? Date()
        comment = "Ersteller: \(product.creator ?? "")"

        // Source must be "world.openfoodfacts.org"
        // Check if source exists and use it. If not yet exists, create the source.
        let sources =  Source.fetchSourcesForName("world.openfoodfacts.org", managedObjectContext: context)
        if let source = sources?.first {
            self.source = source
//            sources?.forEach{ print("Source name: \($0.name ?? "Source has no name")") }
        } else {
            self.source = Source.createSourceWithName("world.openfoodfacts.org", inManagedObjectContext: context)
        }

        // Check if brand exists and use it. If not yet exists, create the brand.
        if let brand = product.brand {
            let brands =  Brand.fetchBrandsForName(brand, managedObjectContext: context)
            if let brand = brands?.first {
                self.brand = brand
//                brands?.forEach{ print("Brand name: \($0.name ?? "Brand has no name")") }
            } else {
                self.brand = Brand.createBrandWithName(brand, inManagedObjectContext: context)
            }
        }
    }


    class func createFromOffProduct(product: OFFProduct, inManagedObjectContext context: NSManagedObjectContext) -> Food {
        
        let food = Food(context: context)
        food.updateFromOffProduct(product: product, inManagedObjectContext: context)
        return food
    }
        
    /// Returns the first food that has the key.
    ///
    /// Needed for foods from Open Foods Facts in order to check if a food with the EAN-code already exists. (In this case the food will be updated but not newly created.)
    ///  - Parameter key: the key from BLS (Bundeslebensmittelschlüssel) or the products EAN code.
    ///  - Parameter context: the managed object context.
    class func foodWithKey(key: String?, inManagedObjectContext context: NSManagedObjectContext) -> Food? {

        if let key = key {
            let request: NSFetchRequest<Food> = Food.fetchRequest()
            request.predicate = NSPredicate(format: "key = '\(key)'")
            
//            print("Request: \(request.description)")
                    
            do {
                let foods = try context.fetch(request)
//                print("Erstes Food: \(String(describing: foods.first))")
                return foods.first
            } catch {
//                print("Error fetching foods for key '\(key)': \(error)")
            }
        }
        return nil
    }
}

extension Food  {

    func nutrientDistributionData() -> [StackedBarNutriendData]? {

        guard let amount = amount?.doubleValue, amount > 0.001 else {
            return nil
        }
        
        let carb          = (self.doubleForKey("totalCarb") ?? 0)         / 1000
        let fat           = (self.doubleForKey("totalFat") ?? 0)          / 1000
        let protein       = (self.doubleForKey("totalProtein") ?? 0)      / 1000
        let dietaryfiber  = (self.doubleForKey("totalDietaryFiber") ?? 0) / 1000
        let water         = (self.doubleForKey("totalWater") ?? 0)        / 1000
        let other = amount - (carb + fat + protein + dietaryfiber + water)
        
        print("amount \(amount)")
        print("carb \(carb)")
        print("fat \(fat)")
        print("protein \(protein)")
        print("fiber \(dietaryfiber)")
        print("water \(water)")
        print("other \(other)")

        let scaleToPercent = 99.8 / amount // Use 99.8 instead of 100 to be sure that the sums are below 100.000 in order to avoid silly plots because sum is slightly over 100.0

        let stackedBarNutrientData: [StackedBarNutriendData] = [
            .init(category: "Kohlehydrate", value: carb * scaleToPercent),
            .init(category: "Fett",         value: fat * scaleToPercent),
            .init(category: "Protein",      value: protein * scaleToPercent),
            .init(category: "Balastst.",    value: dietaryfiber * scaleToPercent),
            .init(category: "Wasser",       value: water * scaleToPercent),
            .init(category: "Sonst.",       value: other * scaleToPercent)
        ]
        
        return stackedBarNutrientData
    }
}


extension Food {
    /// Returns an array with some dummy foods for testing purposes.
    /// - Parameter context: the context for core data.
    /// - Returns: An array of foods, where the name contains the date such that they can be found and deleted easily.
    class func dummyFoods(context: NSManagedObjectContext) -> [Food] {
        let dummyFood1: Food = {
            let food = Food(context: context)
            food.name = "Dummy Food 1, Leckerer Donut" + Date().formatted(date: .abbreviated, time: .shortened) + Date().ISO8601Format()
            food.comment = "Ein unnötiger Kommentar"
            food.totalCarb = 12.0
            food.totalFat = 23.0
            food.totalProtein = 14.0
            food.totalEnergyCals = 200.0
            food.totalAlcohol = 4.0
            food.totalWater = 55.0
            food.totalDietaryFiber = 32.0
            food.totalOrganicAcids = 0.4
            food.totalSalt = 0.3
            food.dateOfLastModification = Date()
            food.carbGlucose = 12.0
            return food
        }()
        
        let dummyFood2: Food = {
            let food = Food(context: context)
            food.name = "Dummy Food 2, Leckere Papricka" + Date().formatted(date: .abbreviated, time: .shortened) + Date().ISO8601Format()
            food.comment = "Ein Kommentar"
            food.totalCarb = 22.0
            food.totalFat = 23.0
            food.totalProtein = 44.0
            food.totalEnergyCals = 100.0
            food.totalAlcohol = 3.0
            food.totalWater = 45.0
            food.totalDietaryFiber = 38.0
            food.totalOrganicAcids = 0.3
            food.totalSalt = 0.2
            food.dateOfLastModification = Date()
            food.carbGlucose = 12.7
            return food
        }()
        return [dummyFood1, dummyFood2]
    }
}
