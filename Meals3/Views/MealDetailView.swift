//
//  MealDetailView.swift
//  Meals3
//
//  Created by Uwe Petersen on 29.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()



struct MealDetailView: View {
    @ObservedObject var meal: Meal
    @State private var birthDate: Date = Date()
    
    @EnvironmentObject var currentMeal: CurrentMeal
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let date = Binding<Date>(
            get: {self.meal.dateOfCreation ?? Date()},
            set: {
                self.meal.dateOfCreation = $0
                self.meal.dateOfLastModification = Date()
                HealthManager.synchronize(self.meal, withSynchronisationMode: .update)
        })
        
        return VStack {
            Form {
                Section(header: Text("Datum und Kommentar"),
                        footer: HStack {
                            Spacer()
                            Text("Letzte Änderung am \(self.dateString(date: self.meal.dateOfLastModification))")
                    })
                            {
                    DatePicker("Datum:", selection: date)
                }
                Section(header: headerView(), footer: footerView()) {
                    MealDetailIngredientsView(meal: meal)
                }
            }
            
            MealDetailViewToolbar()
        }
        .navigationBarTitle("Mahlzeit-Details")
        .navigationBarItems(trailing: EditButton().padding())
        .onDisappear(){
            print("MealDetailView disappeared.")
            if self.viewContext.hasChanges {
                try? self.meal.managedObjectContext?.save()
            }
        }
        .onAppear() {
            print("MealDetaliView appeared.")
            self.currentMeal.meal = self.meal
        }
    }
    
    func headerView() -> some View {
        Text(mealNutrientsString(meal: currentMeal.meal))
    }
    
    func footerView() -> some View {
        HStack {
            Spacer()
            Text("\(meal.ingredients?.count ?? 0) Zutaten, insgesamt \(amountString(meal: currentMeal.meal)) g")
        }
    }
    
     var calsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        numberFormatter.zeroSymbol = "0"
        return numberFormatter
    }()
    
     var zeroMaxDigitsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        numberFormatter.zeroSymbol = "0"
        return numberFormatter
    }()
    

    func amountString(meal: Meal) -> String {
        if let amount = meal.amount {
            return zeroMaxDigitsNumberFormatter.string(from: amount) ?? ""
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
        
        let aFormatter = DateFormatter()
        aFormatter.timeStyle = .short
        aFormatter.dateStyle = .full
        aFormatter.doesRelativeDateFormatting = true // "E.g. yesterday
        //        aFormatter.locale = Locale(identifier: "de_DE")
        return aFormatter.string(from: date)
    }
}


//struct MealDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailView()
//    }
//}
