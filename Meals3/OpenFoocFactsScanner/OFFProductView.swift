//
//  OffProductView.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI


fileprivate let numberFormatter: NumberFormatter =  {() -> NumberFormatter in
    let numberFormatter = NumberFormatter()
    numberFormatter.zeroSymbol = "0"
    numberFormatter.usesSignificantDigits = true
    return numberFormatter
}()


fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

struct OFFProductView: View {
    @ObservedObject var offManager: OFFManager
    
    var hugo = numberFormatter.string(from: NSNumber(12))
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            List() {
                
                if let response = offManager.offResponse, response.status == 0 {
                    
                    Section(header: Text("Kein Lebensmittel gefunden:"), footer: Text(" ")) {
                        HStack() {
                            Spacer()
                            Text("Kein Lebensmittel gefunden.")
                            Spacer()
                        }
                        rowView(leftString: "EAN-Code", rightString: "\(response.code)")
                        rowView(leftString: "Status", rightString: "\(response.status) (\(response.statusVerbose))")
                            .padding(.bottom)
                    }
                }
                
                if let response = offManager.offResponse, let product = offManager.offResponse?.product {
                    
                    Section(header: Text("LEBENSMITTEL GEFUNDEN:"), footer: Text(" ")) {
                        
                        HStack() {
                            Spacer()
                            Text("\(product.name ?? "kein Name angegeben") von \(product.brand ?? "keine Marke angegeben.")")
                            Spacer()
                        }
                        rowView(leftString: "EAN-Code", rightString: "\(response.code)")
                        rowView(leftString: "Status", rightString: "\(response.status) (\(response.statusVerbose))")
                    }
                    
                    Section(header: Text("NÄHRWERTE JE 100g:"), footer: Text(" ")) {
                        
                        rowViewForFloat(leftString: "Energie", value: product.energyCals, unit: "kcal")
                        rowViewForFloat(leftString: "Kohlehydrate", value: product.carbs, unit: "g")
                        rowViewForFloat(leftString: "Protein", value: product.protein, unit: "g")
                        rowViewForFloat(leftString: "Fett", value: product.fat, unit: "g")
                        rowViewForFloat(leftString: "Ges. Fetts.", value: product.saturatedFat, unit: "g")
                        rowViewForFloat(leftString: "Zucker", value: product.sugar, unit: "g")
                        SwiftUI.Group() {
                            rowViewForFloat(leftString: "Balaststoffe", value: product.fiber, unit: "g")
                            rowViewForFloat(leftString: "Salz", value: product.salt, unit: "g")
                            
                            rowView(leftString: "Erstellt", rightString: product.created != nil ? dateFormatter.string(from: product.created!) : "k.A.")
                            rowView(leftString: "Letzte Änderung", rightString: product.lastModified != nil ? dateFormatter.string(from: product.lastModified!) : "k.A.")
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }


    @ViewBuilder func rowView(leftString: String, rightString: String) -> some View {
        HStack {
            Text(leftString)
            Spacer()
            Text(rightString)
        }
    }

    @ViewBuilder func rowViewForFloat(leftString: String, value: Float?, unit: String) -> some View {
        HStack {
            Text(leftString)
            Spacer()
            if let value = value, let numberString = numberFormatter.string(from: NSNumber(value: value)) {
                Text(numberString + " " + unit)
            } else {
                Text("k. A.")
            }
        }
    }

}

//struct OffProductView_Previews: PreviewProvider {
//    static var previews: some View {
//        OffProductView()
//    }
//}
