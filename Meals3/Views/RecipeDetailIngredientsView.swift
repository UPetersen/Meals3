//
//  RecipeDetailIngredients.swift
//  Meals3
//
//  Created by Uwe Petersen on 05.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct RecipeDetailIngredientsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var recipe: Recipe
    
    var body: some View {
        return List {
            if recipe.filteredAndSortedIngredients() == nil {
                Text("Leeres Rezept").foregroundColor(Color(.placeholderText))
            } else {
                ForEach(recipe.filteredAndSortedIngredients()!) { (recipeIngredient: RecipeIngredient) in
                    RecipeIngredientRowView(ingredient: recipeIngredient)
                }
                .onDelete() { IndexSet in
                    print("Deleting recipe ingredient from food.")
                    for index in IndexSet {
                        print (recipe.filteredAndSortedIngredients()![index].description)
                        viewContext.delete(recipe.filteredAndSortedIngredients()![index])
                    }
                    viewContext.processPendingChanges() // Needed. Otherwhise the deleted ingredient might be counted. Save would work, too.
                    recipe.food?.updateNutrients(amount: .sumOfAmountsOfRecipeIngredients, managedObjectContext: viewContext)
                    recipe.dateOfLastModification = Date()
                    if viewContext.hasChanges {
                        try? viewContext.save()
                    }
                }
            }
        }
    }
}



//struct RecipeDetailIngredients_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeDetailIngredients()
//    }
//}
