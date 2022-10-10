//
//  StackedNutrientsBarChart.swift
//  Meals3
//
//  Created by Uwe Petersen on 07.10.22.
//  Copyright © 2022 Uwe Petersen. All rights reserved.
//

import SwiftUI
import Charts

struct NutrientDistributionBarChartData: Identifiable {
    var category: NutrientDistributionBarChartDataCategory
    var value: Double
    var id = UUID()
}

/// Data type used for nutrient categories (i.e. carb, fat, ...) displayed in nutrient distribution bar chart.
enum NutrientDistributionBarChartDataCategory {
    case carb
    case fat
    case protein
    case fiber
    case water
    case other
    
    /// Key to get nutrient data from core data databse
    var key: String {
        switch self {
        case .carb:    return "totalCarb"
        case .fat:     return "totalFat"
        case .protein: return "totalProtein"
        case .fiber:   return "totalDietaryFiber"
        case .water:   return "totalWater"
        case .other:   return ""
        }
    }
    /// String to be used in legend of bar chart
    var name: String {
        switch self {
        case .carb:    return "Kohlehydrate"
        case .fat:     return "Fett"
        case .protein: return "Protein"
        case .fiber:   return "Balaststoffe"
        case .water:   return "Wasser"
        case .other:   return "Sonstige"
        }
    }
    /// Fill color for bar chart
    var color: Color {
        switch self {
        case .carb: return .orange
        case .fat: return .purple
        case .protein: return .yellow
        case .fiber: return Color(red: 114/255, green: 80/255, blue: 56/255)
        case .water: return .cyan
        case .other: return .gray
        }
    }
}
    
struct NutrientsDistributionBarChart: View {
    
    var stackedBarNutrientData: [NutrientDistributionBarChartData]
    
    var body: some View {
        
        Text("Nährwerteverteilung")
        
        Chart {
            ForEach(stackedBarNutrientData) { shape in
                BarMark(
                    x: .value("Total Count", shape.value)
                    //                        y: .value("Shape Type", shape.type)
                )
                .foregroundStyle(by: .value("Shape Color", shape.category.name))
                .annotation(position: .overlay, alignment: .center) { // Plot values into the bars 
                    if shape.value >= 5 {
                        Text("\(shape.value, format: .number.precision(.fractionLength(0)))")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
        }
        .chartForegroundStyleScale([
            NutrientDistributionBarChartDataCategory.carb.name:    NutrientDistributionBarChartDataCategory.carb.color,
            NutrientDistributionBarChartDataCategory.fat.name:     NutrientDistributionBarChartDataCategory.fat.color,
            NutrientDistributionBarChartDataCategory.protein.name: NutrientDistributionBarChartDataCategory.protein.color,
            NutrientDistributionBarChartDataCategory.fiber.name:   NutrientDistributionBarChartDataCategory.fiber.color,
            NutrientDistributionBarChartDataCategory.water.name:   NutrientDistributionBarChartDataCategory.water.color,
            NutrientDistributionBarChartDataCategory.other.name:   NutrientDistributionBarChartDataCategory.other.color
        ])
    }
}

struct NutrientsDistributionBarChart_Previews: PreviewProvider {

    static var stackedBarNutrientData: [NutrientDistributionBarChartData] = [
        .init(category: .carb, value: 50),
        .init(category: .fat, value: 4),
        .init(category: .protein, value: 10),
        .init(category: .fiber, value: 20),
        .init(category: .water, value: 10),
        .init(category: .other, value: 6)
    ]

    static var previews: some View {
        Form() {
            NutrientsDistributionBarChart(stackedBarNutrientData: stackedBarNutrientData)
        }
    }
}



/// Protocol used for meal, recipe and food, to provice bar chart data from these types.
/// Using a default implementation, the chart data is provided without any extra code in Meal, Recipe or Food.
protocol NutrientDistributionBarChartDataProvider: HasNutrients {
    func nutrientDistributionBarChartData() -> [NutrientDistributionBarChartData]?
}

extension NutrientDistributionBarChartDataProvider {
    func nutrientDistributionBarChartData() -> [NutrientDistributionBarChartData]? {
        guard let amount = amount?.doubleValue, amount > 0.001 else {
            return nil
        }
                
        let carb          = (self.doubleForKey(NutrientDistributionBarChartDataCategory.carb.key) ?? 0)    / 1000 // correct for micro grams
        let fat           = (self.doubleForKey(NutrientDistributionBarChartDataCategory.fat.key) ?? 0)     / 1000 // correct for micro grams
        let protein       = (self.doubleForKey(NutrientDistributionBarChartDataCategory.protein.key) ?? 0) / 1000 // correct for micro grams
        let fiber         = (self.doubleForKey(NutrientDistributionBarChartDataCategory.fiber.key) ?? 0)   / 1000 // correct for micro grams
        
        var water         = (self.doubleForKey(NutrientDistributionBarChartDataCategory.water.key) ?? 0)   / 1000 // correct for micro grams

        // Water has to be treaded separately for Recipes, where the amount of water could have been reduced due to heating.
        // This is known from the users entry of the weight of the Recipe after heating (as stored in 'amount').
        if self is Recipe {
            let waterLostFromHeating = (self as! Recipe).amountOfAllIngredients  - amount
            water = water - waterLostFromHeating
            
            // By this calculaton, the amount of water in the recipe, technically could become negative. In real, this is not possible.
            // For ingredients (e.g. from open food facts, that have not values for water entered) this substraction could also lead to negative values for water.
            // In order to avoid such negative water values, these values are leveled up to zero. (As a consequence 'other' has to be reduced accordingly)
            water = max(water, 0.0)
        }

        let other = amount - (carb + fat + protein + fiber + water)

        let scaleToPercent = 99.8 / amount // Use 99.8 instead of 100 to be sure that the sums are below 100.000 in order to avoid silly plots because sum is slightly over 100.0 due to rounding errors.
        let stackedBarNutrientData: [NutrientDistributionBarChartData] = [
            .init(category: .carb,    value: carb *    scaleToPercent),
            .init(category: .fat,     value: fat *     scaleToPercent),
            .init(category: .protein, value: protein * scaleToPercent),
            .init(category: .fiber,   value: fiber *   scaleToPercent),
            .init(category: .water,   value: water *   scaleToPercent),
            .init(category: .other,   value: other *   scaleToPercent)
        ]

        return stackedBarNutrientData
    }
}

