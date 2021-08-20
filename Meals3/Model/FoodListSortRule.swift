//
//  FoodListSortRule.swift
//  meals
//
//  Created by Uwe Petersen on 08.09.15.
//  Copyright © 2015 Uwe Petersen. All rights reserved.
//

import Foundation

enum FoodListSortRule: String {
    
    case nameAscending = "Name"
    case totalEnergyCalsDescending = "Kalorien"
    case totalCarbDescending = "Kohlehydrate"
    case totalProteinDescending = "Protein"
    case totalFatDescending = "Fett"
    case groupThenSubGroupThenNameAscending = "Gruppe"
    case fattyAcidCholesterolDescending = "Cholesterin"
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .nameAscending:
            return [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        case .totalEnergyCalsDescending:
            return [NSSortDescriptor(key: "totalEnergyCals", ascending: false, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        case .totalCarbDescending:
            return [NSSortDescriptor(key: "totalCarb", ascending: false, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        case .totalProteinDescending:
            return [NSSortDescriptor(key: "totalProtein", ascending: false, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        case .totalFatDescending:
            return [NSSortDescriptor(key: "totalFat", ascending: false, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        case .fattyAcidCholesterolDescending:
            return [NSSortDescriptor(key: "fattyAcidCholesterol", ascending: false, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        case .groupThenSubGroupThenNameAscending:
            //            sortDescriptors = [NSSortDescriptor(key: "group.name", ascending: true, selector: "localizedCaseInsensitiveCompare:"),
            //                NSSortDescriptor(key: "subGroup.name", ascending: true, selector: "localizedCaseInsensitiveCompare:"),
            //                NSSortDescriptor(key: "name", ascending: true, selector: "localizedCaseInsensitiveCompare:")]
            //            sectionNameKeyPath = "group.name"
            
            return [NSSortDescriptor(key: "subGroup.name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            //            sortDescriptors = [NSSortDescriptor(key: "key", ascending: true, selector: "localizedCaseInsensitiveCompare:")]
            //            sectionNameKeyPath = "key"
            
            //          Does not work this way and seems to be quite complicated. Need to use an extra (conputed?) property or some other technique
            //        case .FrequencyDescendingThenNameAscending:
            //            return [NSSortDescriptor(key: "countOfMealIngredients", ascending: false, selector: "localizedCaseInsensitiveCompare:")]
        }
    }
    
    var sectionNameKeyPath: String? {
        switch self {
        case .nameAscending:
            return "uppercaseFirstLetterOfName"
        case .totalEnergyCalsDescending:
            return nil
        case .totalCarbDescending:
            return nil
        case .totalProteinDescending:
            return nil
        case .totalFatDescending:
            return nil
        case .fattyAcidCholesterolDescending:
            return nil
        case .groupThenSubGroupThenNameAscending:
            //            sectionNameKeyPath = "group.name"
            //            sectionNameKeyPath = "key"
            return "subGroup.name"
        }
    }
}
