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
    @ObservedObject var searchViewModel: SearchViewModel
        
    private var nsFetchRequest: NSFetchRequest<Food> // used to derive the number of fetched foods without actually fetching any
    @FetchRequest var foods: FetchedResults<Food>    // result of the fetch
    // Alternatively those two lines:
    //    private var fetchRequest: FetchRequest<Food>
    //    private var foods: FetchedResults<Food> { fetchRequest.wrappedValue }
    
    // Number of foods in database that match the fetch request.
    private var totalFoodsCount: Int {
//        print ("Calculate total foods count")
        return (try? viewContext.count(for: nsFetchRequest)) ?? -1
    }
    
    // Handling of paging and displaying corresponding information in small header line.
    @State private var didScrollDown = false
    @State private var didScrollUp = false
    @State private var headerAppeared = false
    @State private var headerDisAppeared = false
    @State private var footerAppeared = false
    @State private var footerDisAppeared = false

    init(searchViewModel: SearchViewModel, ingredientCollection: T) {
        print("initialization of search results")
        
        self.searchViewModel = searchViewModel
        self.ingredientCollection = ingredientCollection
        
        let request = searchViewModel.foodsFetchRequest()
        _foods = FetchRequest(fetchRequest: request)
        // Alternatively
        //        self.fetchRequest = FetchRequest(fetchRequest: request) // request for displaying foods
        
        request.fetchLimit = 0
        request.fetchOffset = 0
        nsFetchRequest = request // request for displaying count of foods with fetchOffest = 0 and fetchLimit = 0
    }
    
    
    var body: some View {
        VStack {
            HStack {  // Header row with count information, e.g. "0 bis 49 von 166"
                Spacer()
                pagingText()
                Spacer()
            }
            .font(.footnote)
            .background(Color(.secondarySystemBackground))
            .frame(height: 10)
            
            List {
                // TODO: remove the invisible header and footer text row and move the test into the ForEach and test every single cell when it appears if it is the first or the last cell and then page up or down. See also https://stackoverflow.com/questions/56893240/is-there-any-way-to-make-a-paged-scrollview-in-swiftui , and there the last post.
                // But maybe this post https://stackoverflow.com/questions/57258846/how-to-make-a-swiftui-list-scroll-automatically/58708206#58708206 is more close to what is needed.
                Text("").frame(width: 0, height: 0)  //.hidden()
                    .onAppear(){ shouldLoadPreviousPage()
                        headerAppeared = true
                        headerDisAppeared = false
                }.onDisappear() {
                    didScrollDown = true
                    
                    headerAppeared = false
                    headerDisAppeared = true
                }
                
                ForEach(foods) { (food: Food) in
                    NavigationLink(destination: LazyView(foodDetailView(food: food)) ) {
                             FoodNutrientsRowView(food: food)
                    }
                }
                
                Text("").frame(width: 0, height: 0)
                    .onAppear(){
                        shouldLoadNextPage()
                        
                        footerAppeared = true
                        footerDisAppeared = false
                }.onDisappear() {
                    footerAppeared = false
                    footerDisAppeared = true
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .environment(\.defaultMinListRowHeight, 1) // for invisible header and footer, which keep this space unfortunately

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
    }
    
    func pagingText() -> Text {
        Text("\(searchViewModel.fetchOffset) bis \(searchViewModel.fetchOffset + foods.endIndex-1) von \(totalFoodsCount), h: \(headerAppeared.description)|\(headerDisAppeared.description), f: \(footerAppeared.description)| \(footerDisAppeared.description)")
    }
        
    @ViewBuilder func foodDetailView(food: Food) -> some View {
        FoodDetailView(ingredientCollection: ingredientCollection, food: food)
    }
    
    func shouldLoadNextPage() {
//        print("should load next page")
//        let newOffset = max ( 0, min(searchViewModel.fetchOffset + 30, totalFoodsCount - searchViewModel.fetchLimit) )
        let newOffset = max ( 0, min(searchViewModel.fetchOffset + 500, totalFoodsCount - searchViewModel.fetchLimit) )
        if searchViewModel.fetchOffset != newOffset {
            searchViewModel.fetchOffset = newOffset
        }
    }
        
    func shouldLoadPreviousPage() {
//        print("should load previous page")
        guard searchViewModel.fetchOffset > 0 && didScrollDown else {
            return
        }
        searchViewModel.fetchOffset = max(0, searchViewModel.fetchOffset - foods.count)
    }
}

//struct SearchResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeneralSearchResultsView(search: Search(), formatter: NumberFormatter())
//    }
//}
