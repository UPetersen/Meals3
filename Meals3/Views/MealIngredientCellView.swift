//
//  MealIngredientCellView.swift
//  Meals3
//
//  Created by Uwe Petersen on 16.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI


// Formatters only created once by putting them here

fileprivate let numberFormatter: NumberFormatter = {
    return NumberFormatter()
}()


/// Shows nutrient compremension data for an ingredient in a meal.
///
/// Example data is
///
/// ` "Kuhmilch 3,5% Fett"`
///
/// `"156 kcal, 11g KH, 8 g Prot, 9 g Fett, 0 g Fruct., 0 g Gluc."`

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
                Text("\(mealIngredient.amount ?? NSNumber(-999), formatter: numberFormatter) g")
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
    /// Returns a String like "44 kcal, 10 g, KH, ..."
    func contentFor(mealIngredient: MealIngredient) -> String {
        let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: mealIngredient.doubleForKey("totalEnergyCals"), formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: mealIngredient.doubleForKey("totalCarb"),    formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: mealIngredient.doubleForKey("totalProtein"), formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: mealIngredient.doubleForKey("totalFat"),     formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: mealIngredient.doubleForKey("carbFructose"), formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let carbGlucose  = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: mealIngredient.doubleForKey("carbGlucose"),  formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " Fruct., " + carbGlucose + " Gluc."
    }
}


//struct MealIngredientCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealIngredientCellView()
//    }
//}
