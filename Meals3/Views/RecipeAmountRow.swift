//
//  RecipeAmountRow.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct RecipeAmountRow: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var recipe: Recipe
    var numberFormatter: NumberFormatter = NumberFormatter()
    
    var body: some View {
        
        let value: Binding<NSNumber?> = Binding(
            get: {self.recipe.amount ?? nil},
            set: {
//                print(self.recipe.amount)
//                print(self.recipe.amountOfAllIngredients)
                self.recipe.amount = $0
//                print(self.recipe.amount)
//                print(self.recipe.amountOfAllIngredients)
//                self.recipe.food?.updateNutrients(managedObjectContext: self.viewContext)
//                print(self.recipe.amount)
//                print(self.recipe.amountOfAllIngredients)

        }
        )
        
        return HStack {
            Text("Gewicht nach Zubereitung:")
            Spacer()
            NSNumberTextField(label: "", value: value, formatter: numberFormatter)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

//struct RecipeAmountRow_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeAmountRow()
//    }
//}