//
//  OffProductView.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct OffProductView: View {
    @ObservedObject var offManager: OffManager
    
    var body: some View {
        
        VStack(alignment: .center) {

            if let response = offManager.offResponse {
                SwiftUI.Group() {
                    rowView(leftString: "EAN-Code", rightString: "\(response.code)")
                    rowView(leftString: "Status", rightString: "\(response.status)")
                    rowView(leftString: "Status", rightString: "\(response.statusVerbose)")
                        .padding(.bottom)
                }
            }
            
            if let product = offManager.offResponse?.product {
                
                SwiftUI.Group() {
                    rowView(leftString: "Name", rightString: "\(product.name ?? "kein Name")")
                    rowView(leftString: "Marke", rightString: "\(product.brand ?? "keine Marke")")
                    rowView(leftString: "Energie", rightString: "\(String(describing: product.energyCals))")
                    rowView(leftString: "Kohlehydrate", rightString: "\(String(describing: product.carbs))")
                    rowView(leftString: "Protein", rightString: "\(String(describing: product.protein))")
                    rowView(leftString: "Fett", rightString: "\(String(describing: product.fat))")
                    rowView(leftString: "Ges. Fetts.", rightString: "\(String(describing: product.saturatedFat))")
                    rowView(leftString: "Zucker", rightString: "\(String(describing: product.sugar))")
                }
                SwiftUI.Group() {
                    rowView(leftString: "Balaststoffe", rightString: "\(String(describing: product.fiber))")
                    rowView(leftString: "Salz", rightString: "\(String(describing: product.salt))")
                        .padding(.bottom)
                    rowView(leftString: "Erstellung", rightString: String(describing: product.created))
                    rowView(leftString: "Letzte Änd.", rightString: String(describing: product.lastModified))
                }
            }
        }
    }


    @ViewBuilder func rowView(leftString: String, rightString: String) -> some View {
        HStack {
            Text(leftString)
            Spacer()
            Text(rightString)
        }.padding(.horizontal)
    }
}

//struct OffProductView_Previews: PreviewProvider {
//    static var previews: some View {
//        OffProductView()
//    }
//}
