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
    @ObservedObject var search: Search
        
    @State private var showingDeleteConfirmation = false
    @State private var indicesToDelete: IndexSet? = IndexSet()
//    @State private var meal: Meal?
    @EnvironmentObject var currentIngredientCollection: CurrentIngredientCollection
//    @EnvironmentObject var currentMeal: Meal
    @EnvironmentObject var currentMeal: CurrentMeal
//    @ObservedObject var ingredients: IngredientCollection

    // Todo: ensure that there always exists a current meal
    
//    @Binding var searchText: String
    @FetchRequest var meals: FetchedResults<Meal>
    
    init(search: Search) {
        self.search = search
        let searchFilter = SearchFilter.Contains
        
        let request = NSFetchRequest<Meal>(entityName: "Meal")
        request.predicate = searchFilter.predicateForMealsWithIngredientsWithSearchText(search.text)
//        request.predicate = searchFilter.predicateForMealsWithIngredientsWithSearchText(searchText.wrappedValue)
        request.fetchBatchSize = 50
        request.fetchLimit = 50  // Speeds up a lot, especially inital loading of this view controller, but needs care
        request.returnsObjectsAsFaults = true   // objects are only loaded, when needed/used -> faster but more frequent disk reads
        request.includesPropertyValues = true   // usefull only, when only relevant properties are read
        request.propertiesToFetch = ["dateOfCreation"] // read only certain properties (others are fetched automatically on demand)
        request.relationshipKeyPathsForPrefetching = ["ingredients", "food"]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.dateOfCreation, ascending: false)]
        self._meals = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        List {
            ForEach(meals){ (meal: Meal) in
                Section(header:
                    NavigationLink(destination: MealDetailView(meal: meal)) {
                        LazyView( MealNutrientsView(meal: meal) )
                    }
                ) {
                    ForEach(meal.filteredAndSortedMealIngredients()!) { (mealIngredient: MealIngredient) in
                        NavigationLink(destination: self.lazyFoodDetailsView(food: mealIngredient.food!)) {
                                    MealIngredientCellView(mealIngredient: mealIngredient)
                        }
                    }
                }
            }
            .onMove(perform: self.move)
            .onDelete { indices in
                print("onDelete")
                self.indicesToDelete = indices
                self.showingDeleteConfirmation = true
            }
        }
        .resignKeyboardOnDragGesture() // must be outermost
        .alert(isPresented: self.$showingDeleteConfirmation){
            return Alert(title: Text("Mahlzeit wirklich löschen?"), message: Text(""),
                         primaryButton: .destructive(Text("Delete")) {
                            if let indices = self.indicesToDelete {
                                self.meals.delete(at: indices, from: self.viewContext)
                                self.currentMeal.meal = Meal.newestMeal(managedObjectContext: self.viewContext)
                                try? self.viewContext.save()
                            }
                },
                         secondaryButton: .cancel())
        }
    }
    
    func lazyFoodDetailsView(food: Food) -> some View {
        LazyView(
            FoodDetailsView(ingredientCollection: self.currentMeal.meal,
//                            FoodDetailsView(ingredientCollection: Meal.newestMeal(managedObjectContext: self.viewContext),
                            food: food)
                .environmentObject( Meal.newestMeal(managedObjectContext: self.viewContext))
        )
    }
    
    func move (from source: IndexSet, to destination: Int) {
        print("Outer move")
        print("From: \(source.indices.endIndex.description)")
        print("To: \(destination)")
    }
    
}

//struct MealsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealsView()
//    }
//}

