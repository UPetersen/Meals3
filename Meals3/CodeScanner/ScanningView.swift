//
//  ScanningView.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct ScanningView: View {
    
//    @EnvironmentObject var offManager: OffManager
    @StateObject private var offManager = OffManager()

    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var currentMeal: CurrentMeal

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isPresentingFouncdABarcodeAlert: Bool = false

    
    var body: some View {
        
        NavigationView {
            
            VStack {
                if offManager.state == .isScanning {
                    CodeScannerView(
                        codeTypes: [.ean13, .ean8],
                        completion: { result in
                            offManager.finishedScanningWithResult(result)
                        }
                    )
                }
                if offManager.state == .isFetching {
                    Spacer()
                    Text("Fetching food data for EAN \(offManager.scannedBarcode ?? "kein Barcod gefunden").").padding()
                    ProgressView()
                    Spacer()
                }
                if offManager.state == .fetchingCompleted, let product = offManager.product  {
                    Spacer()
                    Text(product.description).padding()
                    Spacer()
                    Button("Zur aktuellen Mahhlzeit hinzufügen.") {
                        self.addProduct()
                        offManager.reset()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }

                Text("Status: \(self.offManager.state.description)")
                    .padding()
                    
            }

            .navigationBarTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    Button("Cancel") {
                                        offManager.reset()
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
            )

        }
        .onAppear() {
            print("Scanning view onAppear")
            self.offManager.scan()
        }
        .onDisappear(perform: {
            print("Scanning view onDisappear")
            self.offManager.reset()
        })


    }
    
    func addProduct() {
        let food = Food.CreateFromOffProduct(product: offManager.product!, inManagedObjectContext: viewContext)
        currentMeal.meal.addIngredient(food: food, amount: NSNumber(0), managedObjectContext: viewContext)
    }

}






struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView()
    }
}

