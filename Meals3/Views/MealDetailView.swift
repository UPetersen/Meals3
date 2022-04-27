//
//  MealDetailView.swift
//  Meals3
//
//  Created by Uwe Petersen on 29.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

fileprivate let formatter: NumberFormatter =  {() -> NumberFormatter in
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = NumberFormatter.Style.decimal
    numberFormatter.maximumFractionDigits = 1
    numberFormatter.roundingMode = NumberFormatter.RoundingMode.halfUp
    numberFormatter.zeroSymbol = "0"
    return numberFormatter
}()

fileprivate let calsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = NumberFormatter.Style.none
    numberFormatter.zeroSymbol = "0"
    return numberFormatter
}()

fileprivate let zeroMaxDigitsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = NumberFormatter.Style.none
    numberFormatter.zeroSymbol = "0"
    return numberFormatter
}()



struct MealDetailView: View {
    @ObservedObject var meal: Meal
    
    @EnvironmentObject var currentMeal: CurrentMeal
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        
        let date = Binding<Date>(
            get: {meal.dateOfCreation ?? Date()},
            set: {
                meal.dateOfCreation = $0
                meal.dateOfLastModification = Date()
                HealthManager.synchronize(meal, withSynchronisationMode: .update)
        })
        
         VStack {
            Form {
                Section(header: Text("Datum und Kommentar"),
                        footer: HStack {
                            Spacer()
                            Text("Letzte Änderung am \(dateString(date: meal.dateOfLastModification))")
                    }) { DatePicker("Datum:", selection: date) }
                
                Section {
                    HStack {
                        Spacer()
                        Text("\(reducedNutrientString(meal: meal))")
                            .font(.headline)
                        Spacer()
                    }
                }
                
                Section(header: headerView(), footer: footerView()) {
                    MealDetailIngredients(meal: meal)
                }
            }
            
            MealDetailViewToolbar(meal: meal)
        }
        .navigationBarTitle("Mahlzeit-Details")
        .toolbar() {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { withAnimation {isShowingDeleteAlert = true} }) {
                    Image(systemName: "trash").padding(.horizontal)
                }
                .alert(isPresented: $isShowingDeleteAlert){ self.deleteAlert() }
 
                EditButton().padding()
            }
        }
        .onDisappear(){
//            print("MealDetailView disappeared.")
            if viewContext.hasChanges {
                try? meal.managedObjectContext?.save()
            }
            // current meal might have changed, since the date of the meal could have changed. Thus update it.
            // Do not compare to this meal, since it could have been deleted and the core data would crash
            currentMeal.updateToNewestMeal(viewContext: viewContext)
        }
    }
    
    @ViewBuilder func headerView() -> some View {
        Text(mealNutrientsString(meal: meal))
    }
    
    @ViewBuilder func footerView() -> some View {
        HStack {
            Spacer()
            Text("\(meal.ingredients?.count ?? 0) Zutaten, insgesamt \(amountString(meal: meal)) g")
        }
    }
    
    func amountString(meal: Meal) -> String {
        if let amount = meal.amount {
            return zeroMaxDigitsNumberFormatter.string(from: amount) ?? ""
        }
        return ""
    }
    
    func reducedNutrientString(meal: Meal?) -> String {
//        print("In reducedNutrientString in MealsDetailView: \(String(describing: meal?.description))")
        if let meal = meal {
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: meal.doubleForKey("totalCarb"),    formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            var fpu = 0.0
            if let protein = meal.doubleForKey("totalProtein"), let fat = meal.doubleForKey("totalFat") {
                fpu = (9.0 * protein + 4.0 * fat) / 100.0 / 1000.0
            }

            return String("\(totalCarb) KH  und   \(formatter.string(from: NSNumber(value: fpu)) ?? "") FPE")
        }
        return ""
    }
    
    func mealNutrientsString(meal: Meal?) -> String {
        if let meal = meal {
            let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: meal.doubleForKey("totalEnergyCals"), formatter: calsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: meal.doubleForKey("totalCarb"),    formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: meal.doubleForKey("totalProtein"), formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: meal.doubleForKey("totalFat"),     formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: meal.doubleForKey("carbFructose"), formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let carbGlucose   = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: meal.doubleForKey("carbGlucose"),  formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " F, " + carbGlucose + " G"
        }
        return ""
    }

    
    func dateString(date: Date?) -> String {
        guard let date = date else { return "no date avaiable" }        
        return dateFormatter.string(from: date)
    }
    
    func deleteAlert() -> Alert {
//        print("delete the meal with confirmation")
        Alert(title: Text("Mahlzeit wirklich löschen?"),
              message: Text(""),
              primaryButton: .destructive(Text("Delete")) {
                HealthManager.synchronize(meal, withSynchronisationMode: .delete)
                viewContext.delete(meal)
                currentMeal.updateToNewestMeal(viewContext: viewContext)
                try? viewContext.save()
                presentationMode.wrappedValue.dismiss()
              },
              secondaryButton: .cancel())
    }
}


//struct MealDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailView()
//    }
//}
