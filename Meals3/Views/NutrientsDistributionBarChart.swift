//
//  StackedNutrientsBarChart.swift
//  Meals3
//
//  Created by Uwe Petersen on 07.10.22.
//  Copyright © 2022 Uwe Petersen. All rights reserved.
//

import SwiftUI
import Charts

struct StackedBarNutriendData: Identifiable {
    var category: String
    var value: Double
    var id = UUID()
}

//        var stackedBarNutrientData: [StackedBarNutriendData] = [
//            .init(category: "Kohlehydrate", value: 50),
//            .init(category: "Fett", value: 4),
//            .init(category: "Protein", value: 10),
//            .init(category: "Balastst.", value: 20),
//            .init(category: "Wasser", value: 10),
//            .init(category: "Sonst.", value: 6)
//        ]

struct NutrientsDistributionBarChart: View {
    
    var stackedBarNutrientData: [StackedBarNutriendData]
    
    var body: some View {
        
        Text("Nährwerteverteilung")
        
        Chart {
            ForEach(stackedBarNutrientData) { shape in
                BarMark(
                    x: .value("Total Count", shape.value)
                    //                        y: .value("Shape Type", shape.type)
                )
                .foregroundStyle(by: .value("Shape Color", shape.category))
                .annotation(position: .overlay, alignment: .center) {
                    if shape.value >= 5 {
                        Text("\(shape.value, format: .number.precision(.fractionLength(0)))")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
        }
        .chartForegroundStyleScale([
            "Kohlehydrate": .orange, "Fett": .purple, "Protein": .yellow, "Balastst.": Color(red: 114/255, green: 80/255, blue: 56/255), "Wasser": .blue, "Sonst.": .gray
        ])
    }
}

struct NutrientsDistributionBarChart_Previews: PreviewProvider {

    static var stackedBarNutrientData: [StackedBarNutriendData] = [
        .init(category: "Kohlehydrate", value: 50),
        .init(category: "Fett", value: 4),
        .init(category: "Protein", value: 10),
        .init(category: "Balastst.", value: 20),
        .init(category: "Wasser", value: 10),
        .init(category: "Sonst.", value: 6)
    ]

    static var previews: some View {
        Form() {
            NutrientsDistributionBarChart(stackedBarNutrientData: stackedBarNutrientData)
        }
    }
}
