//
//  MealIngredientCellView.swift
//  Meals3
//
//  Created by Uwe Petersen on 16.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct MealIngredientCellView: View {
    @Environment(\.managedObjectContext) var viewContext
    var mealIngredient: MealIngredient
    @State private var task: Task?
    @State private var showingAddOrChangeAmountOfFoodView = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> // This is a dummy, unfortunately I do not know a better way

    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(mealIngredient.food?.name ?? "-")
                    .lineLimit(1)
                Spacer()
                Text("\(mealIngredient.amount ?? NSNumber(-999), formatter: NumberFormatter()) g")
                    .foregroundColor(Color(.systemBlue))
                    .onTapGesture {
                        print("tapped")
                        self.task = .changeAmountOfIngredient(self.mealIngredient as Ingredient)
                        self.showingAddOrChangeAmountOfFoodView = true
                }
            }
            Text(self.contentFor(mealIngredient: mealIngredient))
                .lineLimit(1)
                .font(.footnote)
        }
            // TODO: hier geht's weiter: optionals rausmachen
        .sheet(isPresented: $showingAddOrChangeAmountOfFoodView, content:{
             AddOrChangeAmountOfFoodView(food: self.mealIngredient.food!,
                                         task: self.task!,
                                         isPresented: self.$showingAddOrChangeAmountOfFoodView, presentationModeOfParentView: self.presentationMode)
                .environment(\.managedObjectContext, self.viewContext)
        })
    }
    
    func stringForNumber (_ number: NSNumber, formatter: NumberFormatter, divisor: Double) -> String {
        return (formatter.string(from: NSNumber(value: number.doubleValue / divisor)) ?? "nan")
    }
    
    // TODO: put formatter into environment or pass it along as parameter
    func contentFor(mealIngredient: MealIngredient) -> String {
        // Returns a String like "44 kcal, 10 g, KH, ..."
        //        let formatter = oneMaxDigitsNumberFormatter
        let formatter = NumberFormatter()
        
        let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: mealIngredient.doubleForKey("totalEnergyCals"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: mealIngredient.doubleForKey("totalCarb"),    formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: mealIngredient.doubleForKey("totalProtein"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: mealIngredient.doubleForKey("totalFat"),     formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: mealIngredient.doubleForKey("carbFructose"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let carbGlucose  = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: mealIngredient.doubleForKey("carbGlucose"),  formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        
        return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " Fruct., " + carbGlucose + " Gluc."
    }
}


//struct MealIngredientCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealIngredientCellView()
//    }
//}
