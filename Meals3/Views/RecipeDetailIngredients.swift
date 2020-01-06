//
//  RecipeDetailIngredients.swift
//  Meals3
//
//  Created by Uwe Petersen on 05.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct RecipeDetailIngredients: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var recipe: Recipe
    
    var body: some View {
        return List {
            if recipe.filteredAndSortedIngredients() == nil {
                Text("Leeres Rezept").foregroundColor(Color(.placeholderText))
            } else {
                ForEach(recipe.filteredAndSortedIngredients()!, id: \.self) { (recipeIngredient: RecipeIngredient) in
                    RecipeIngredientRow(ingredient: recipeIngredient)
                }
                .onDelete() { IndexSet in
                    print("Deleting recipe ingredient from food.")
                    for index in IndexSet {
                        print (self.recipe.filteredAndSortedIngredients()![index].description)
                        self.viewContext.delete(self.recipe.filteredAndSortedIngredients()![index])
                    }
                    self.recipe.food?.updateNutrients(managedObjectContext: self.viewContext)
                    if self.viewContext.hasChanges {
                        try? self.viewContext.save()
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
