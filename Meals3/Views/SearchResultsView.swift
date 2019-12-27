//
//  SearchResultsView.swift
//  Meals3
//
//  Created by Uwe Petersen on 23.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData



struct SearchResultsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var search: Search
    var formatter: NumberFormatter
    
    private var nsFetchRequest: NSFetchRequest<Food> // used to derive the number of fetched foods without actually fetching any
    @FetchRequest var foods: FetchedResults<Food> // result of the fetch
    // Alternatively
    //    private var fetchRequest: FetchRequest<Food>
    //    private var foods: FetchedResults<Food> { fetchRequest.wrappedValue }

    private var totalFoodsCount: Int { (try? viewContext.count(for: self.nsFetchRequest)) ?? -1 }

    @State private var didScrollDown = false
    @State private var didScrollUp = false
    
    @State private var headerAppeared = false
    @State private var headerDisAppeared = false
    @State private var footerAppeared = false
    @State private var footerDisAppeared = false

    init(search: Search, formatter: NumberFormatter) {
        self.search = search
        self.formatter = formatter
        
        let searchFilter = SearchFilter.Contains
        let predicates = [search.foodListType.predicate, searchFilter.predicateForSearchText(search.text)].compactMap{$0}
        
        let request = NSFetchRequest<Food>(entityName: "Food")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = search.sortRule.sortDescriptors
        request.returnsObjectsAsFaults = true   // objects are only loaded, when needed/used -> faster but more frequent disk reads
        request.includesPropertyValues = true   // usefull only, when only relevant properties are read
        
        request.fetchBatchSize = 50
        request.fetchOffset = search.fetchOffset // needed for paging throuhg results
        request.fetchLimit = search.fetchLimit // Speeds up a lot, especially inital loading of this view controller, but needs care
        request.propertiesToFetch = ["name", "totalEnergyCals", "totalCarb", "totalProtein", "totalFat", "carbFructose", "carbGlucose"]   // read only certain properties (others are fetched automatically on demand)
        
        self._foods = FetchRequest(fetchRequest: request)
        // Alternatively
        //        self.fetchRequest = FetchRequest(fetchRequest: request) // request for displaying foods
        
        request.fetchLimit = 0
        request.fetchOffset = 0
        self.nsFetchRequest = request // request for displaying count of foods with fetchOffest = 0 and fetchLimit = 0

        
        // TODO: avoid the need of the following lines and fix the error with the "Ä" in the name
        //        var sectionNameKeyPath = search.sortRule.sectionNameKeyPath
        //        if search.sortRule == FoodListSortRule.NameAscending && (search.foodListType == FoodListType.All || search.foodListType == FoodListType.BLS) {
        //            sectionNameKeyPath = nil
        //        }
    }
    
    
    var body: some View {
        VStack {
            HStack {  // Header row with count information, e.g. "0 bis 49 von 166"
                Spacer()
                Text("\(self.search.fetchOffset) bis \(self.search.fetchOffset + self.foods.endIndex-1) von \(self.totalFoodsCount), h: \(self.headerAppeared.description)|\(self.headerDisAppeared.description), f: \(self.footerAppeared.description)| \(self.footerDisAppeared.description)")
                Spacer()
            }
            .font(.footnote)
            .background(Color(.secondarySystemBackground))
            .frame(height: 10)
            
            List {
                Text("").frame(width: 0, height: 0).hidden()
                    .onAppear(){ self.shouldScrollUp()
//                        }
                        self.headerAppeared = true
                        self.headerDisAppeared = false
                }.onDisappear() {
                    self.didScrollDown = true
                    
                    self.headerAppeared = false
                    self.headerDisAppeared = true
                }
                
                ForEach(foods) { (food: Food) in
                    VStack(alignment: .leading) {
                        Text(food.name ?? "")
                        Text(self.nutrientStringForFood(food: food))
                            .font(.footnote)
                    }
                }
                
                Text("").frame(width: 0, height: 0)
                    .onAppear(){
                        self.shouldScrollDown()
                        
                        self.footerAppeared = true
                        self.footerDisAppeared = false
                }.onDisappear() {
                    self.footerAppeared = false
                    self.footerDisAppeared = true
                }
            }
            .environment(\.defaultMinListRowHeight, -10)
                .resignKeyboardOnDragGesture() // must be outside of the list
                .onTapGesture(count: 2) {
                    print("double tap")
                    self.search.fetchOffset = 0 // double tap moves to top of list (by refetching with offset = 0)
                }
                .onTapGesture { // single tap prints debug data to console
                    print("startIndex: \(self.foods.startIndex)")
                    print("endIndex: \(self.foods.endIndex)")
                    print("count: \(self.foods.count)")
                    print("underestimatedCount: \(self.foods.underestimatedCount)")
                    print("indices: \(self.foods.indices.description)")
                    print("count all: \(self.totalFoodsCount)")
                    print("offset: \(self.search.fetchOffset)")
                    print("limit: \(self.search.fetchLimit)")
            }
        }
    }
    
    func shouldScrollDown() {
        print("should scroll down")
        let newOffset = max ( 0, min(self.search.fetchOffset + 30, self.totalFoodsCount - self.search.fetchLimit) )
        if self.search.fetchOffset != newOffset {
            self.search.fetchOffset = newOffset
        }
    }
        
    func shouldScrollUp() {
        print("should scoll up")
        guard self.search.fetchOffset > 0 && self.didScrollDown else {
            return
        }
        self.search.fetchOffset = max(0, self.search.fetchOffset - self.foods.count)
    }
    
    
    func nutrientStringForFood(food: Food?) -> String {
        if let food = food {
            let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: food.doubleForKey("totalEnergyCals"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: food.doubleForKey("totalCarb"),    formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: food.doubleForKey("totalProtein"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: food.doubleForKey("totalFat"),     formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: food.doubleForKey("carbFructose"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let carbGlucose   = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: food.doubleForKey("carbGlucose"),  formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " P, " + totalFat + " F, " + carbFructose + " Fr., " + carbGlucose + " Gl."
        }
        return "no data"
    }
}

//struct SearchResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchResultsView(search: Search(), formatter: NumberFormatter())
//    }
//}
