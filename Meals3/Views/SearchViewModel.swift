//
//  Search.swift
//  Meals3
//
//  Created by Uwe Petersen on 23.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//
import Combine
import CoreData

class SearchViewModel: ObservableObject {
    @Published var text: String = "" {
        didSet {
            fetchOffset = 0
//            print("did set fetchoffset to zero")
        } // Enforces refetch of data if search string is modified
    }
    @Published var filter: SearchFilter = .contains
    @Published var sortRule: FoodListSortRule = .nameAscending
    @Published var selection: FoodListSelection = .mealIngredients
    var fetchLimit: Int = 500 // 500 ... iPhone 14, formerly: 25
    @Published var fetchOffset: Int = 0
    
    init() {
        
    }

    
    
    /// Returns a NSFetchRequest for foods that matches the search.
    ///
    /// Batch size, offset, limit and other properties are chosen such to achieve speed performance when scrolling the resulting list with SwiftUI. Which was especially important on an iPhone 6S Plus in time where there was already an iPhone 13 available.
    /// - Returns: NSFetchRequest
    func foodsFetchRequest() -> NSFetchRequest<Food> {
        
        let predicates = [selection.predicate, filter.predicateForSearchText(text)].compactMap{$0}
        
        let request = NSFetchRequest<Food>(entityName: "Food")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = sortRule.sortDescriptors
        request.returnsObjectsAsFaults = true   // objects are only loaded, when needed/used -> faster but more frequent disk reads
        request.includesPropertyValues = true   // usefull only, when only relevant properties are read
        
        request.fetchBatchSize = 50
        request.fetchBatchSize = 500
        request.fetchOffset = fetchOffset // needed for paging through results
        request.fetchLimit = fetchLimit   // Speeds up a lot, especially inital loading of this view controller, but needs care
        request.propertiesToFetch = ["name", "totalEnergyCals", "totalCarb", "totalProtein", "totalFat", "carbFructose", "carbGlucose"]   // read only certain properties (others are fetched automatically on demand)
        return request
    }
    
    func mealsViewFetchRequest() -> NSFetchRequest<Meal> {
        
        let predicate = filter.predicateForMealsWithIngredientsWithSearchText(text)
        
        let request = NSFetchRequest<Meal>(entityName: "Meal")
//        request.predicate = searchFilter.predicateForMealsWithIngredientsWithSearchText(search.text)
        request.predicate = predicate
        request.fetchBatchSize = 25
        request.fetchLimit = 25  // Speeds up a lot, especially inital loading of this view controller, but needs care
        request.fetchBatchSize = 500
        request.fetchLimit = 500  // iPhone 14: 500 is easy.
        // TODO: double check whether request.returnsObjectsAsFaults = true really speeds up in our case. 2021-12-05: Seems no difference
//        request.returnsObjectsAsFaults = true   // objects are only loaded, when needed/used -> faster but more frequent disk reads
        request.includesPropertyValues = true   // usefull only, when only relevant properties are read
//        request.propertiesToFetch = ["dateOfCreation", "dateOfLastModification"] // read only certain properties (others are fetched automatically on demand (and that is the problem for entities with only frew properties like Meal, so do not use on meal!!!!)
        request.relationshipKeyPathsForPrefetching = ["ingredients", "food"]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.dateOfCreation, ascending: false)]
        return request
    }


    
}
