//
//  FoodListSelection.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import Foundation

enum FoodListSelection: String {
    case favorites = "Favoriten"
    case recipes = "Rezepte"
    case lastWeek = "Letzte Woche"
    case mealIngredients = "Gegessene"
    case ownEntries = "Eingetragene"
    case bls = "Bundeslebensmittelschlüssel"
    case all = "Alle"
    case openFoodFacts = "Open Food Facts"
    
    var predicate: NSPredicate? {
        switch self {
        case .all:
            return nil
        case .favorites:
            return NSPredicate(format: "favoriteListItem != nil")
        case .recipes:
            return NSPredicate(format: "recipe != nil")
        case .lastWeek:
            let lastWeek = Date(timeIntervalSinceNow: -86400.0*7.0)
            return NSPredicate(format: "SUBQUERY(mealIngredients, $x, $x.meal.dateOfCreation >= %@).@count != 0", lastWeek as CVarArg)
        case .ownEntries:
            return NSPredicate(format: "source = nil")
        case .mealIngredients:
            return NSPredicate(format: "mealIngredients.@count > 0")
        case .bls:
//            return NSPredicate(format: "source != nil")
            return NSPredicate(format: "source.name beginswith[c] %@", "BLS" as CVarArg)
        case .openFoodFacts:
            return NSPredicate(format: "source.name contains[c] %@", "openfoodfacts.org" as CVarArg)

        }
    }
}
