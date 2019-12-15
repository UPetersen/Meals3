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
    
    //    @FetchRequest(
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Meal.dateOfCreation, ascending: false)],
    //        animation: .default)
    //    var mealsss: FetchedResults<Meal>
    
    @State private var showingDeleteConfirmation = false
    @State private var indicesToDelete: IndexSet? = IndexSet()
    // Todo: ensure that there always exists a current meal
    
    @Binding var searchText: String
    @FetchRequest var meals: FetchedResults<Meal>
    init(searchText: Binding<String>) {
        
        let searchFilter = SearchFilter.Contains
        self._searchText = searchText
        
        let request = NSFetchRequest<Meal>(entityName: "Meal")
        request.predicate = searchFilter.predicateForMealsWithIngredientsWithSearchText(searchText.wrappedValue)
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
            ForEach(meals, id: \.self) { (meal: Meal) in
                
                Section(header:
                    NavigationLink(destination: MealDetailView(meal: meal)) {
                        MealNutrientsView(meal: meal)
                    }
                ) {
                    MealNutrientsView(meal: meal)
                    ForEach(meal.filteredAndSortedMealIngredients()!, id: \.self) { (mealIngredient: MealIngredient) in
                        NavigationLink(destination:
                        FoodDetailsView(nutrientCollection: Meal.newestMeal(managedObjectContext: self.viewContext) as NutrientCollection,
                                        food: mealIngredient.food!)
                            .environmentObject( Meal.newestMeal(managedObjectContext: self.viewContext))) {
                            MealIngredientCellView(mealIngredient: mealIngredient )
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
            
        .alert(isPresented: self.$showingDeleteConfirmation){
            return Alert(title: Text("Mahlzeit wirklich löschen?"), message: Text(""),
                         primaryButton: .destructive(Text("Delete")) {
                            if let indices = self.indicesToDelete {
                                self.meals.delete(at: indices, from: self.viewContext)
                                try? self.viewContext.save()
                            }
                },
                         secondaryButton: .cancel())
        }
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

