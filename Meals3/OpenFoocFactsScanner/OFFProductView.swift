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
                    
                    Section() {
                        HStack() {
                            Spacer()
                            Text("Kein Lebensmittel gefunden.")
                            Spacer()
                        }
                        rowView(leftString: "EAN-Code", rightString: "\(response.code)")
                        rowView(leftString: "Status", rightString: "\(response.status) (\(response.statusVerbose))")
                            .padding(.bottom)
                    }
                    Section() {
                        HStack() {
                            Spacer()
                            Button("Das Lebensmittel in Open Foods Facts hinzufügen.") {
                                // I don't know how to open the app on the phone directly (if installed), thus, open the app in the app store.
                                UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/open-food-facts-product-scan/id588797948")!, options: [:], completionHandler: nil)
                            }
                            .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                }
                
                if let response = offManager.offResponse, let product = offManager.offResponse?.product {
                    
                    Section() {
                        
                        HStack() {
                            if let url = product.imageFrontSmallURL {
                                AsyncImage(url: URL(string: url))
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Spacer()
                                Text("\(product.name ?? "Kein Name angegeben")")
                                    .font(.title3)
                                    .fixedSize(horizontal: false, vertical: true) // enable line break, see https://stackoverflow.com/a/57794877/3687284
                                    .border(Color.green)
                                Text("\(product.brand ?? "Keine Marke angegeben.")").foregroundColor(.secondary)
                                Spacer()
                                Text("EAN \(response.code)").foregroundColor(.secondary)
                            }
                            .border(Color.red)
                            Spacer()
                        }
//                        .scaledToFit()
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
                        }
                    }
                    Section() {
                        
                        SwiftUI.Group() {
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
