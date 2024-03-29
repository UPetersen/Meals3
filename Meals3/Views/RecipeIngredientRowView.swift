//
//  RecipeIngredientRowView.swift
//  Meals3
//
//  Created by Uwe Petersen on 05.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import SwiftUI

fileprivate let formatter = NumberFormatter()

struct RecipeIngredientRowView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var ingredient: RecipeIngredient

    @State private var task: AddOrChangeTask?
    @State private var showingAddOrChangeAmountOfFoodView = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> // This is a dummy, unfortunately I do not know a better way

    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(ingredient.food?.name ?? "-")
                    .lineLimit(1)
                Spacer()
                Text("\(ingredient.amount ?? NSNumber(-999), formatter: NumberFormatter()) g")
                    .foregroundColor(Color(.systemBlue))
                    .onTapGesture {
                        task = .changeAmountOfIngredient(ingredient as Ingredient)
                        showingAddOrChangeAmountOfFoodView = true
                }
            }
            Text(contentFor(ingredient: ingredient))
                .lineLimit(1)
                .font(.footnote)
        }
        // TODO: hier geht's weiter: optionals rausmachen
        .sheet(isPresented: $showingAddOrChangeAmountOfFoodView) {
            AddOrChangeAmountOfIngredientView(food: ingredient.food!,
                                              task: .changeAmountOfIngredient(ingredient as Ingredient),
                                              isPresented: $showingAddOrChangeAmountOfFoodView,
                                              presentationModeOfParentView: presentationMode)
        }
    }
    
    func stringForNumber (_ number: NSNumber, formatter: NumberFormatter, divisor: Double) -> String {
        return (formatter.string(from: NSNumber(value: number.doubleValue / divisor)) ?? "nan")
    }
    
    func contentFor(ingredient: RecipeIngredient) -> String {
        // Returns a String like "44 kcal, 10 g, KH, ..."
        
        let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: ingredient.doubleForKey("totalEnergyCals"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: ingredient.doubleForKey("totalCarb"),    formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: ingredient.doubleForKey("totalProtein"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: ingredient.doubleForKey("totalFat"),     formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: ingredient.doubleForKey("carbFructose"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let carbGlucose  = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: ingredient.doubleForKey("carbGlucose"),  formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        
        return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " Fruct., " + carbGlucose + " Gluc."
    }
}

//struct RecipeIngredientRow_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeIngredientRow()
//    }
//}
