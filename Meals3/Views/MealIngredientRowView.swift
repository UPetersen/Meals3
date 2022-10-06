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
/// `"156 kcal, 11g KH, 8 g Prot, 9 g Fett, 0 g Fruct., 0 g Gluc."`

//struct MealIngredientCellView: View {
struct MealIngredientRowView: View, Equatable {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var mealIngredient: MealIngredient
    @State private var showingAddOrChangeAmountOfFoodView = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> // This is a dummy, unfortunately I do not know a better way

    var body: some View {
        
        HStack {
            VStack (alignment: .leading) {
                if let brandName = mealIngredient.food?.brand?.name {
                    Text("\(mealIngredient.food?.name ?? "-") von \(brandName)").lineLimit(1)
                } else{
                    Text(mealIngredient.food?.name ?? "-").lineLimit(1)
                }
                Text(smallContentFor(mealIngredient: mealIngredient))
                    .lineLimit(1)
                    .font(.footnote)
            }
            Spacer()
            Text("\(mealIngredient.amount ?? NSNumber(-999), formatter: numberFormatter) g")
                .foregroundColor(Color(.systemBlue))
                .onTapGesture {
                    self.showingAddOrChangeAmountOfFoodView = true
                }
        }
        // TODO: hier geht's weiter: optionals rausmachen
        .sheet(isPresented: $showingAddOrChangeAmountOfFoodView) {
            AddOrChangeAmountOfIngredientView(food: mealIngredient.food!,
                                              task: .changeAmountOfIngredient(mealIngredient as Ingredient),
                                              isPresented: $showingAddOrChangeAmountOfFoodView,
                                              presentationModeOfParentView: presentationMode)
        }
    }
    
    // FIXME: equatable is probably not correct here, if this view is also used, within a search where only the ingredients are displayed that match the search term.
    static func == (lhs: MealIngredientRowView, rhs: MealIngredientRowView) -> Bool {
//        print("Using equatable on MealIngredientCellView")
        return lhs.mealIngredient.food?.name == rhs.mealIngredient.food?.name &&
            lhs.mealIngredient.amount == rhs.mealIngredient.amount &&
            lhs.mealIngredient.meal?.dateOfLastModification == rhs.mealIngredient.meal?.dateOfLastModification
    }
    
    
    /// Returns a String like "44 kcal, 10 g, KH, ..."
    func contentFor(mealIngredient: MealIngredient) -> String {
//        print("MealIngredientCellView func contentFor(MealIngredient:): \(mealIngredient.description)")
        let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: mealIngredient.doubleForKey("totalEnergyCals"), formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: mealIngredient.doubleForKey("totalCarb"),    formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: mealIngredient.doubleForKey("totalProtein"), formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: mealIngredient.doubleForKey("totalFat"),     formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: mealIngredient.doubleForKey("carbFructose"), formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        let carbGlucose  = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: mealIngredient.doubleForKey("carbGlucose"),  formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
        return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " Fruct., " + carbGlucose + " Gluc."
    }
    
    func smallContentFor(mealIngredient: MealIngredient) -> String {
//        print("MealIngredientCellView func smallContentFor(MealIngredient:): \(mealIngredient.description)")
        let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: mealIngredient.doubleForKey("totalCarb"),    formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
//        return "fünf"
        return totalCarb + " KH"
    }
}


//struct MealIngredientCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealIngredientCellView()
//    }
//}
