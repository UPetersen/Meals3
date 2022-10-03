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
    @ObservedObject var searchViewModel: SearchViewModel
    private var ingredientsPredicate: NSPredicate?
        
    @State private var showingDeleteConfirmation = false
    @State private var indicesToDelete: IndexSet? = IndexSet()
    @EnvironmentObject var currentMeal: CurrentMeal

    @FetchRequest var meals: FetchedResults<Meal>
    
    private var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
        
    init(searchViewModel: SearchViewModel) {
        print("Init of meals view")
        self.searchViewModel = searchViewModel

        self._meals = FetchRequest(fetchRequest: searchViewModel.mealsViewFetchRequest())
        
        let searchFilter = SearchFilter.contains
        self.ingredientsPredicate = searchFilter.shortPredicateForMealsWithIngredientsWithSearchText(searchViewModel.text)
    }
    
    var body: some View {

        ScrollViewReader { proxy in
            List {
//                ForEach(meals, id: \.mealID) { meal in
                ForEach(meals) { meal in
                    Section(header: NavigationLink(destination: MealDetailView(meal: meal) ) {
                        LazyView( MealsNutrientsSectionView(meal: meal) )
                    }) {
                        ForEach(meal.filteredAndSortedMealIngredients(predicate: ingredientsPredicate)!) {  mealIngredient in
                            NavigationLink(destination: lazyFoodDetailView(food: mealIngredient.food!)) {
                                MealIngredientRowView(mealIngredient: mealIngredient) // .equatable()
                            }
                        }
                        .onDelete() { indexSet in
                            deleteIngredients(atIndexSet: indexSet, fromMeal: meal)
                        }
                        .foregroundColor(meal == currentMeal.meal ? Color(.label) : Color(.secondaryLabel)) // Different color for current meal
                    }
                }
                .onMove(perform: move)
            }
            .id("ListID") // Workaround for iOS 16: jump to always to top (which is valid since the newest meal is always the topmost and when searching you also want the top of the list)
            .onChange(of: searchViewModel.text, perform: {_ in proxy.scrollTo("ListID", anchor: .top)}) // scroll to top of the list, when editing search field (incl.
            
//            .onChange(of: searchViewModel.text, perform: {_ in proxy.scrollTo(meals.first, anchor: .top)}) // scroll to top, when editing search field (incl. cancel)
//            .onChange(of: currentMeal.meal) { meal in proxy.scrollTo(meal.mealID, anchor: .top) } // scroll to current meal if current meal changes
            

        }
        .onReceive(didSave) { _ in
//            print("Received self.didSave")
            // FIXME: This could be the cause of crashes when entering text into the search field.
            currentMeal.objectWillChange.send() // update this ui
         }
            
        .alert(isPresented: self.$showingDeleteConfirmation){
            return Alert(
                title: Text("Mahlzeit wirklich löschen?"),
                message: Text(""),
                primaryButton: .destructive(Text("Delete")) {
                    if let indices = indicesToDelete {
                        meals.delete(at: indices, from: viewContext)
                        try? viewContext.save()
                        currentMeal.updateToNewestMeal(viewContext: viewContext)
                    }
                },
                secondaryButton: .cancel())
        }
    }
    
    @ViewBuilder func lazyFoodDetailView(food: Food) -> some View {
        LazyView( FoodDetailView(ingredientCollection: currentMeal.meal, food: food))
//        FoodDetailView(ingredientCollection: self.currentMeal.meal, food: food)
    }

    func deleteIngredients(atIndexSet indexSet: IndexSet, fromMeal meal: Meal) {
        for index in indexSet {
            if let ingredients = meal.filteredAndSortedMealIngredients() {
                viewContext.delete(ingredients[index])
            }
        }
        HealthManager.synchronize(meal, withSynchronisationMode: .update)
        try? viewContext.save()
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

