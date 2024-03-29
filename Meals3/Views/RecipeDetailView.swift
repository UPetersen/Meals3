//
//  RecipeDetail.swift
//  Meals3
//
//  Created by Uwe Petersen on 05.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//
import SwiftUI
import CoreData

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

struct RecipeDetailView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) var viewContext
    
    let explanationString = "Beim Zubereiten eines Rezeptes kann sich das Gewicht durch erhitzen (und einhergehendem Verdampfen von Wasseranteilen) verringern und dadurch der Nährwertanteil pro 100g erhöhen. Geben sie hier das Gewicht des fertig zubereiteten Gerichts an, damit dies bei der Nährwertberechnung entsprechend berücksichtigt wird.\nBeachten Sie, dass dieser Wert mit jeder Änderung von Zutaten überschrieben wird."
    
    var body: some View {
    
        let name = Binding<String>(
            get: {recipe.food?.name ?? ""},
            set: {
                recipe.food?.name = $0
                recipe.dateOfCreation = Date()
                recipe.dateOfLastModification = Date()
        })
        let comment = Binding<String>(
            get: {recipe.food?.comment ?? ""},
            set: {
                recipe.food?.comment = $0
                recipe.dateOfCreation = Date()
                recipe.dateOfLastModification = Date()
        })
        
        return VStack {
            
            Form {
                Section(header: Text("Name und Kommentar"), footer: Text("Letzte Änderung am \(dateString(date: recipe.dateOfLastModification))")) {
                    TextField("Name des erzeugten Rezepts bzw. Lebensmittels", text: name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Notizen ...", text: comment,  axis: .vertical)
                        .lineLimit(3...10)
                }

                Section(footer: Text(explanationString)) {
                    RecipeAmountRowView(recipe: recipe)
                    Text("Amount is \(recipe.amount ?? NSNumber(value: -999))")
                }
                
                Section() {
                    if let nutrientDistributionBarChartData = recipe.nutrientDistributionBarChartData() {
                        NutrientsDistributionBarChart(stackedBarNutrientData: nutrientDistributionBarChartData)
                    }
                }

                Section(header: headerView(), footer: footerView()) {
                    RecipeDetailIngredientsView(recipe: recipe)
                }
            }
            RecipeDetailViewToolbar(recipe: recipe)
        }
            .navigationBarTitle("Rezept-Details")
            .navigationBarItems(trailing: EditButton().padding())
//        .resignKeyboardOnDragGesture()
    }
    
    func headerView() -> some View {
        Text("Zutaten")
    }
    
    func footerView() -> some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                HStack {
                    Text("Nährwerte pro 100 g:")
                    Spacer()
                }
                if recipe.food != nil {
                    Text(recipe.food!.nutrientStringForFood(formatter: zeroMaxDigitsNumberFormatter))
                }
                Text("")
                HStack {
                    Text("Nährwerte des Rezepts ingesamt:")
                    Spacer()
                }
                Text(recipeNutrientsString(recipe: recipe))
                Text("\(recipe.ingredients?.count ?? 0) Zutaten, insgesamt \(amountOfAllIngredientsString(recipe: recipe)) g")
            }
        }
    }
    
    func amountOfAllIngredientsString(recipe: Recipe) -> String {
        let amount = NSNumber(value: recipe.amountOfAllIngredients)
            return zeroMaxDigitsNumberFormatter.string(from: amount) ?? ""
    }
    
    func recipeNutrientsString(recipe: Recipe?) -> String {
        if let recipe = recipe {
            let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: recipe.doubleForKey("totalEnergyCals"), formatter: calsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: recipe.doubleForKey("totalCarb"),    formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: recipe.doubleForKey("totalProtein"), formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: recipe.doubleForKey("totalFat"),     formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: recipe.doubleForKey("carbFructose"), formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let carbGlucose   = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: recipe.doubleForKey("carbGlucose"),  formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " F, " + carbGlucose + " G"
        }
        return ""
    }

    
    func dateString(date: Date?) -> String {
        guard let date = date else { return "no date avaiable" }
        
        let aFormatter = DateFormatter()
        aFormatter.timeStyle = .medium
        aFormatter.dateStyle = .full
        aFormatter.doesRelativeDateFormatting = true // "E.g. yesterday
        //        aFormatter.locale = Locale(identifier: "de_DE")
        return aFormatter.string(from: date)
    }
    
}




struct RecipeDetail_Previews: PreviewProvider {
    
        static var previews: some View {
            return NavigationView {
            RecipeDetailView(recipe: Recipe())
        }
    }

}
