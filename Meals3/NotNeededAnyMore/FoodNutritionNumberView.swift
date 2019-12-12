//
//  FoodNutritionCellView.swift
//  Meals3
//
//  Created by Uwe Petersen on 16.11.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import Foundation

struct FoodNutritionNumberView: View {
    
    var text: String = ""
    @Binding var value: NSNumber?
    var unit: String = "g"

     let numberFormatter: NumberFormatter =  {() -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.zeroSymbol = "0"
        numberFormatter.usesSignificantDigits = true
//        print("In the number formatter in FoodNutricionCellView.")
        return numberFormatter
    }()
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            if value == nil {
                Text(unit)
            } else {
                Text("\(value!, formatter: numberFormatter) \(unit)")
            }
        }
        
    }
}

struct FoodDetailCellView_Previews: PreviewProvider {
    @State static private var number0: NSNumber? = NSNumber(0.00994)
    @State static private var number1: NSNumber? = NSNumber(9.0)
    @State static private var number2: NSNumber? = NSNumber(9.5)
    @State static private var number3: NSNumber? = NSNumber(9.55)
    @State static private var number4: NSNumber? = NSNumber(9.555)

    static var previews: some View {
        VStack {

            FoodNutritionNumberView(text: "Kohlehydrate", value: $number0)
            Divider()
            FoodNutritionNumberView(text: "Vitamin E-Tocopheroläquivalent", value: $number1, unit: "µg")
            Divider()
            FoodNutritionNumberView(text: "Fett", value: $number2)
            Divider()
            FoodNutritionNumberView(text: "Oligosaccharide, resorbierbar (3 - 9 M)", value: $number3)
            Divider()
            FoodNutritionNumberView(text: "Natrium", value: $number4, unit: "mg")
            Divider()

        }.padding()
        
    }
}
