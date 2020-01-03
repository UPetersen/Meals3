//
//  MealIngredientsView.swift
//  Meals3
//
//  Created by Uwe Petersen on 30.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI


struct MealIngredientsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var meal: Meal
    
    var body: some View {
        return List {
            if meal.filteredAndSortedMealIngredients() == nil {
                Text("Leere Mahlzeit").foregroundColor(Color(.placeholderText))
            } else {
                ForEach(meal.filteredAndSortedMealIngredients()!, id: \.self) { (mealIngredient: MealIngredient) in
                    MealIngredientCellView(mealIngredient: mealIngredient)
                }
                .onDelete() { IndexSet in
                    print("Deleting meal ingredient from food.")
                    for index in IndexSet {
                        print (self.meal.filteredAndSortedMealIngredients()![index].description)
                        self.viewContext.delete(self.meal.filteredAndSortedMealIngredients()![index])
                    }
                    if self.viewContext.hasChanges {
                        try? self.viewContext.save()
                        //                        HealthManager.synchronize(meal, withSynchronisationMode: .update)
                    }
                }
            }
        }
    }
}

//struct MealIngredientsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealIngredientsView()
//    }
//}
