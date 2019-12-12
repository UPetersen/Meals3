//
//  FoodNumberCell.swift
//  Meals3
//
//  Created by Uwe Petersen on 01.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct FoodNumberCell: View {
    
    var numberFormatter: NumberFormatter = NumberFormatter()
    var text: String = "No text given"
    @Binding var value: NSNumber?
    var unit: String = "g"

    var body: some View {
        HStack {
            Text(text)
            Spacer()
            NSNumberTextField(label: "", value: $value, formatter: numberFormatter)
            Text(unit)
        }
    }
}

struct FoodNumberCell_Previews: PreviewProvider {
    @State static var value: NSNumber? = NSNumber(12.0)
    static var title = String(#file.split(separator: "/").last ?? "file not found")

    static var previews: some View {
        NavigationView{
            Form {
                FoodNumberCell(value: $value)
                    .navigationBarTitle(title)
            }
        }
    }
}
