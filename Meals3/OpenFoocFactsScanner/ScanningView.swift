//
//  ScanningView.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct OFFView: View {
    
//    @EnvironmentObject var offManager: OffManager
    @StateObject private var offManager = OFFManager()

    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var currentMeal: CurrentMeal

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isPresentingFouncdABarcodeAlert: Bool = false

    
    var body: some View {
        
        NavigationView {
            
            VStack {
                if offManager.state == .isScanning {
                    ZStack(alignment: .bottom) {
                        CodeScannerView(
                            codeTypes: [.ean13, .ean8],
                            completion: { result in
                                offManager.finishedScanningWithResult(result)
                            }
                        )
                        
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(Color.white)
                                .opacity(0.5)
                                .frame(width: 70, height: 70)

                            TorchView().scaleEffect(2.5)
                        }.padding()
                    }
                }
                
                if offManager.state == .isFetching {
                    Spacer()
                    Text("Fetching food data for EAN \(offManager.code ?? "kein Barcod gefunden").").padding()
                    ProgressView()
                    Spacer()
                }
                
                if offManager.state == .fetchingCompleted {
                    
                    Spacer()
                    OFFProductView(offManager: offManager)
//                    Text(offManager.offResponse?.description ?? "no response").padding()
                    Spacer()
                    
                    // Button to handle product, if a product was found
                    if offManager.productFound  {
                        Button("Zur Mahhlzeit hinzufügen\n(aktualisiert, falls schon vorhanden).") { addProduct() }
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
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
        
        if let product = offManager.offResponse?.product {

            // Check if product is already as food in local database
            if let food = Food.foodWithKey(key: product.code, inManagedObjectContext: viewContext) {
                food.updateFromOffProduct(product: product, inManagedObjectContext: viewContext)
                currentMeal.meal.addIngredient(food: food, amount: NSNumber(0), managedObjectContext: viewContext)
            } else {
                let food = Food.createFromOffProduct(product: product, inManagedObjectContext: viewContext)
                currentMeal.meal.addIngredient(food: food, amount: NSNumber(0), managedObjectContext: viewContext)
            }
        }
        offManager.reset()
        self.presentationMode.wrappedValue.dismiss()
    }

    func updateWithProduct() {
        if let product = offManager.offResponse?.product, let food = Food.foodWithKey(key: product.code, inManagedObjectContext: viewContext) {
            food.updateFromOffProduct(product: product, inManagedObjectContext: viewContext)
        }
        offManager.reset()
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func productAlreadyInDatabase(product: OFFProduct?) -> Bool {
        if let product = product {
            if Food.foodWithKey(key: product.code, inManagedObjectContext: viewContext) != nil {
                return true
            }
        }
        return false
    }
    
}






struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        OFFView()
    }
}

