//
//  CurrentMeal.swift
//  Meals3
//
//  Created by Uwe Petersen on 02.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData

/// Holds the (current, i.e. most recent) meal, using the `dateOfCreation` property.
///
/// In the meals view, foods can be added only to the topmost (i.e. 'current' or 'most recent' meal).
/// This is being handled by this class. 
///
/// Convention: Each view that has the possiibility to call `GeneralSearch` or `FoodDetail` (both of which can be used to add foods as ingredients to the current meal or reciple) has to set the current meal accordingly. This should be done in `.onAppear()`. Further more, if a meal is deleted or a meal is created, the current meal has to be updated. Generally, if a meal is not selected directle, the current meal is the newest meal available.
class CurrentMeal: ObservableObject {
    @Published private(set) var meal: Meal {
        willSet {
//            debugPrint("Will set current Meal to \(newValue.description)")
        }
    }
//    init(_ meal: Meal) {
//        self.meal = meal
//    }
    
    /// Initializes the current meal by assigning it to the newest meal, which is therefore fetched from the database.
    /// - Parameter viewContext: Must be the view context of the SwiftUI views
    init(viewContext: NSManagedObjectContext) {
        self.meal = Meal.newestMeal(managedObjectContext: viewContext)
    }
    
    /// Updates the current meal by assigning it to the newest meal, which is therefore fetched from the database.
    /// - Parameter viewContext: Must be the view context of the SwiftUI views
    func updateToNewestMeal(viewContext: NSManagedObjectContext) {
        self.meal = Meal.newestMeal(managedObjectContext: viewContext)
    }
    
    /// Updates the current meal by comparing it to the respective meal.
    ///
    /// This is faster than fetching the newest meal from the database, but there is a caveat:
    /// If the respective meal is the current meal then the comparison is useless. To avoid this the two meals are compared and if they are equal `updateToNewestMeal(viewContext: NSManagedObjectContext)` is used.
    /// - Parameter mealToCompareTo: Meal which is used to compare the dateOfCreation and decide which one is newer and shal be the current meal.
    /// - Parameter viewContext: Must be the view context of the SwiftUI views
    func updateByComparisonTo(_ mealtoCompareTo: Meal, viewContext: NSManagedObjectContext) {
        if meal == mealtoCompareTo {
            updateToNewestMeal(viewContext: viewContext)
        } else {
            self.meal = self.meal.dateOfCreation! > mealtoCompareTo.dateOfCreation! ? meal : mealtoCompareTo // faster than looking in the database.
        }
    }
}
