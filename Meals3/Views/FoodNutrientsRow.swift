//
//  FoodNutrientsView.swift
//  Meals3
//
//  Created by Uwe Petersen on 28.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct FoodNutrientsRow: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var food: Food
    var formatter: NumberFormatter

    var body: some View {
        
        VStack(alignment: .leading) {
            Text(food.name ?? "")
            Text(self.nutrientStringForFood(food: food))
                .font(.footnote)
        }
    }
    
    func nutrientStringForFood(food: Food?) -> String {
        if let food = food {
            let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: food.doubleForKey("totalEnergyCals"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: food.doubleForKey("totalCarb"),    formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: food.doubleForKey("totalProtein"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: food.doubleForKey("totalFat"),     formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: food.doubleForKey("carbFructose"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            let carbGlucose   = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: food.doubleForKey("carbGlucose"),  formatter: formatter, inManagedObjectContext: viewContext) ?? ""
            return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " P, " + totalFat + " F, " + carbFructose + " Fr., " + carbGlucose + " Gl."
        }
        return "no data"
    }
}

struct FoodNutrientsView_Previews: PreviewProvider {
    static var previews: some View {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let food: Food = {
            let food = Food(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            food.name = "leckerer Donut"
            food.comment = "Ein unnötiger Kommentar"
            food.totalCarb = 12.0
            food.totalFat = 23.0
            food.totalProtein = 14.0
            food.totalEnergyCals = 200.0
            food.totalAlcohol = 4.0
            food.totalWater = 55.0
            food.totalDietaryFiber = 32.0
            food.totalOrganicAcids = 0.4
            food.totalSalt = 0.3
            food.dateOfLastModification = Date()
            food.carbGlucose = 12.0
            
            return food
        }()
        
        let formatter: NumberFormatter =  {() -> NumberFormatter in
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.maximumFractionDigits = 1
            numberFormatter.roundingMode = NumberFormatter.RoundingMode.halfUp
            numberFormatter.zeroSymbol = "0"
            return numberFormatter
        }()

        return NavigationView {
            List {
                FoodNutrientsRow(food: food, formatter: formatter)
                    .environment(\.managedObjectContext, context)
                    .navigationBarTitle("Lebensmittelsuche")
            }
        }
    }
}
