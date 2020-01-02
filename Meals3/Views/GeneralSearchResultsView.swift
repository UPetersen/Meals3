//
//  GeneralSearchResultsView.swift
//  Meals3
//
//  Created by Uwe Petersen on 23.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData



struct GeneralSearchResultsView<T>: View where T: IngredientCollection  {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var ingredientCollection: T
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

    init(search: Search, formatter: NumberFormatter, ingredientCollection: T) {
        print("initialization of search results")
        
        self.search = search
        self.formatter = formatter
        self.ingredientCollection = ingredientCollection
        
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
                // TODO: remove the invisible header and footer text row and move the test into the ForEach and test every single cell when it appears if it is the first or the last cell and then page up or down. See also https://stackoverflow.com/questions/56893240/is-there-any-way-to-make-a-paged-scrollview-in-swiftui , and there the last post.
                // But maybe this post https://stackoverflow.com/questions/57258846/how-to-make-a-swiftui-list-scroll-automatically/58708206#58708206 is more close to what is needed.
                Text("").frame(width: 0, height: 0)  //.hidden()
                    .onAppear(){ self.shouldLoadPreviousPage()
                        self.headerAppeared = true
                        self.headerDisAppeared = false
                }.onDisappear() {
                    self.didScrollDown = true
                    
                    self.headerAppeared = false
                    self.headerDisAppeared = true
                }
                
                ForEach(foods) { (food: Food) in
                    NavigationLink(destination: LazyView(self.foodDetailsView(food: food)) ) {
                             FoodNutrientsRowView(food: food, formatter: self.formatter)
                    }
                }
                
                Text("").frame(width: 0, height: 0)
                    .onAppear(){
                        self.shouldLoadNextPage()
                        
                        self.footerAppeared = true
                        self.footerDisAppeared = false
                }.onDisappear() {
                    self.footerAppeared = false
                    self.footerDisAppeared = true
                }
            }
                    .onAppear() {
                        print("GeneralSearchResultsView appears")
                        print(self.viewContext.description)
                }
                .environment(\.defaultMinListRowHeight, 1) // for invisible header and footer, which keep this space unfortunately
                .resignKeyboardOnDragGesture() // must be outside of the list

//                .onTapGesture(count: 2) {
//                    print("double tap")
//                    self.search.fetchOffset = 0 // double tap moves to top of list (by refetching with offset = 0)
//                }
//                .onTapGesture { // single tap prints debug data to console
//                    print("startIndex: \(self.foods.startIndex)")
//                    print("endIndex: \(self.foods.endIndex)")
//                    print("count: \(self.foods.count)")
//                    print("underestimatedCount: \(self.foods.underestimatedCount)")
//                    print("indices: \(self.foods.indices.description)")
//                    print("count all: \(self.totalFoodsCount)")
//                    print("offset: \(self.search.fetchOffset)")
//                    print("limit: \(self.search.fetchLimit)")
//            }
        }
        .onAppear() {
            print(self.formatter.description)
        }
    }
        
    func foodDetailsView(food: Food) -> some View {
        FoodDetailsView(ingredientCollection: self.ingredientCollection,
                        food: food)
            .environmentObject( Meal.newestMeal(managedObjectContext: self.viewContext))
    }
    
    func shouldLoadNextPage() {
        print("should load next page")
        let newOffset = max ( 0, min(self.search.fetchOffset + 30, self.totalFoodsCount - self.search.fetchLimit) )
        if self.search.fetchOffset != newOffset {
            self.search.fetchOffset = newOffset
        }
    }
        
    func shouldLoadPreviousPage() {
        print("should load previous page")
        guard self.search.fetchOffset > 0 && self.didScrollDown else {
            return
        }
        self.search.fetchOffset = max(0, self.search.fetchOffset - self.foods.count)
    }
}

//struct SearchResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeneralSearchResultsView(search: Search(), formatter: NumberFormatter())
//    }
//}
