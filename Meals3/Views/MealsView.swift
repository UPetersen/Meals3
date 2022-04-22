//
//  MealsView.swift
//  Meals3
//
//  Created by Uwe Petersen on 11.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData

struct MealsView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var search: SearchViewModel
    private var ingredientsPredicate: NSPredicate?
        
    @State private var showingDeleteConfirmation = false
    @State private var indicesToDelete: IndexSet? = IndexSet()
    @EnvironmentObject var currentMeal: CurrentMeal

    @FetchRequest var meals: FetchedResults<Meal>
    
//    private let scrollingProxy = ListScrollingProxy() // proxy helper
//    @State private var scrollingProxy: ListScrollingProxy = ListScrollingProxy() // proxy helper
    private var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
        
    init(search: SearchViewModel) {
        print("Init of meals view")
        self.search = search
        let searchFilter = SearchFilter.contains
        
        let request = NSFetchRequest<Meal>(entityName: "Meal")
        request.predicate = searchFilter.predicateForMealsWithIngredientsWithSearchText(search.text)
//        request.predicate = searchFilter.predicateForMealsWithIngredientsWithSearchText(searchText.wrappedValue)
        request.fetchBatchSize = 25
        request.fetchLimit = 25  // Speeds up a lot, especially inital loading of this view controller, but needs care
        request.fetchBatchSize = 20
        request.fetchLimit = 20  // Speeds up a lot, especially inital loading of this view controller, but needs care
        // TODO: double check whether request.returnsObjectsAsFaults = true really speeds up in our case. 2021-12-05: Seems no difference
//        request.returnsObjectsAsFaults = true   // objects are only loaded, when needed/used -> faster but more frequent disk reads
        request.includesPropertyValues = true   // usefull only, when only relevant properties are read
//        request.propertiesToFetch = ["dateOfCreation", "dateOfLastModification"] // read only certain properties (others are fetched automatically on demand (and that is the problem for entities with only frew properties like Meal, so do not use on meal!!!!)
        request.relationshipKeyPathsForPrefetching = ["ingredients", "food"]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.dateOfCreation, ascending: false)]
        self._meals = FetchRequest(fetchRequest: request)
        
        self.ingredientsPredicate = searchFilter.shortPredicateForMealsWithIngredientsWithSearchText(search.text)
//        self.ingredientsPredicate = searchFilter.shortPredicateForMealsWithIngredientsWithSearchText(search.debouncedText)

// Color stuff for lists see: https://izziswift.com/swiftui-list-color-background/
//        UITableView.appearance().backgroundColor = .red
//        UITableViewCell.appearance().backgroundColor = .red
//        UITableView.appearance().tableFooterView = UIView()

    }
    
    var body: some View {

        ScrollViewReader { proxy in
            List {
                ForEach(meals) { meal in
                    Section(header:
                                NavigationLink(destination: MealDetailView(meal: meal)
//                                    .environment(\.managedObjectContext, viewContext)
//                                    .environmentObject(currentMeal)
                                ) {
                        LazyView( MealsNutrientsView(meal: meal) )
                    })
                    {
                        ForEach(meal.filteredAndSortedMealIngredients(predicate: ingredientsPredicate)!) {  mealIngredient in
                            NavigationLink(destination: lazyFoodDetail(food: mealIngredient.food!)) {
                                MealIngredientCellView(mealIngredient: mealIngredient) // .equatable()
                            }
                        }
                        .onDelete() { indexSet in
                            deleteIngredients(atIndexSet: indexSet, fromMeal: meal)
                        }
                    }
                    .id(meal) // needed for scrolling to top
                }
                .onMove(perform: move)
            }
            .onChange(of: search.text, perform: {_ in proxy.scrollTo(meals.first, anchor: .top)}) // scroll to top, when editing search field (incl. cancel)
            .onChange(of: currentMeal.meal) { meal in proxy.scrollTo(meal, anchor: .top) } // scroll to current meal if current meal changes
            
        }
        .onReceive(didSave) { _ in
//            print("Received self.didSave")
            // FIXME: This could be the cause of crashes when entering text into the search field.
            currentMeal.objectWillChange.send() // update this ui
         }

        
//        .onAppear() {
//            self.currentMeal.meal = Meal.newestMeal(managedObjectContext: self.viewContext)
//        }
            
        .alert(isPresented: self.$showingDeleteConfirmation){
            return Alert(title: Text("Mahlzeit wirklich löschen?"), message: Text(""),
                         primaryButton: .destructive(Text("Delete")) {
                            if let indices = indicesToDelete {
                                meals.delete(at: indices, from: viewContext)
                                try? viewContext.save()
                                currentMeal.meal = Meal.newestMeal(managedObjectContext: viewContext)
                            }
                },
                         secondaryButton: .cancel())
        }
    }
    
    @ViewBuilder func lazyFoodDetail(food: Food) -> some View {
//        FoodDetail(ingredientCollection: self.currentMeal.meal, food: food)
//            .environmentObject( Meal.newestMeal(managedObjectContext: self.viewContext))
        
        LazyView( FoodDetailView(ingredientCollection: currentMeal.meal, food: food))
//        FoodDetailView(ingredientCollection: self.currentMeal.meal, food: food)
    }

    func deleteIngredients(atIndexSet indexSet: IndexSet, fromMeal meal: Meal) {
        print("Deleting meal ingredient from food.")
        for index in indexSet {
            if let ingredients = meal.filteredAndSortedMealIngredients() {
                viewContext.delete(ingredients[index])
            }
        }
        HealthManager.synchronize(meal, withSynchronisationMode: .update)
        try? viewContext.save()
//        currentMeal.objectWillChange.send() // update this ui
    }

    func move (from source: IndexSet, to destination: Int) {
        print("Outer move")
        print("From: \(source.indices.endIndex.description)")
        print("To: \(destination)")
    }
//    func moveInner (from source: IndexSet, to destination: Int) {
//        print("Inner move")
//        print("From: \(source.indices.endIndex.description)")
//        print("To: \(destination)")
//    }
}

//struct MealsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealsView()
//    }
//}

