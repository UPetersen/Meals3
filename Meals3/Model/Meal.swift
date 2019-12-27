//
//  Meal.swift
//  Meals3
//
//  Created by Uwe Petersen on 02.11.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData

//extension Event {
//    static func create(in managedObjectContext: NSManagedObjectContext){
//        let newEvent = self.init(context: managedObjectContext)
//        newEvent.timestamp = Date()
//
//        do {
//            try  managedObjectContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//    }
//}

extension Meal {
    
    func filteredAndSortedMealIngredients(predicate: NSPredicate? = nil) -> [MealIngredient]? {
        if let mealIngredients = self.ingredients {
            // Meal has meal ingredients.
            var filteredAndSortedMealIngredients = mealIngredients
            // Filter if a predicate is given (text in searchbar), which needs NSSet.
            if let predicate = predicate {
                filteredAndSortedMealIngredients = mealIngredients.filtered(using: predicate) as NSSet
            }
            // Sort thereafter and store in view model
            let sortDescriptor = NSSortDescriptor(key: "food.name", ascending: true)
            if let filteredAndSortedMealIngredients = filteredAndSortedMealIngredients.sortedArray(using: [sortDescriptor]) as? [MealIngredient] {
                return filteredAndSortedMealIngredients
            }
        } else {
            return nil // Meal is empty (i.e. has no meal ingredients).
        }
        return nil
    }

}

extension Meal: Identifiable {
    
}

extension Collection where Element == Meal, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }
 
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
