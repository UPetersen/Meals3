//
//  ScanningView.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct OFFView: View {
    @ObservedObject var meal: Meal

    @StateObject private var offManager = OFFManager()
    @Environment(\.managedObjectContext) var viewContext
//    @EnvironmentObject var currentMeal: CurrentMeal
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                if offManager.state == .isScanning {
                    VStack(alignment: .center) {
                        Text("Kamera auf den Barcode der Verpackung richten.")
                        ZStack(alignment: .bottom) {
                            CodeScannerView(
                                codeTypes: [.ean13, .ean8],
                                completion: { result in
                                    offManager.finishedScanningWithResult(result)
                                }
                            )
                            TorchView()
                                .padding()
                        }
                    }
                }
                
                if offManager.state == .isFetching {
                    Spacer()
                    Text("Fetching food data for EAN \(offManager.code ?? "kein Barcode gefunden").").padding()
                    ProgressView()
                    Spacer()
                }
                
                if offManager.state == .fetchingCompleted {
                    
                    OFFProductView(offManager: offManager)
                    
                    // Button to use product, if a product was found
                    if offManager.productFound  {
                        Button(action: { addProduct() }) {
                            ZStack() {
                                Image(systemName: "arrow.2.circlepath")
                                    .resizable()
//                                    .foregroundColor(Color(.systemBackground))
                                    .frame(width: 40*1.1, height: 34*1.1)
                                Image(systemName: "plus")
                            }
                        }.padding()
                        
//                        Button("Zur Mahlzeit hinzufügen\n(aktualisiert, falls schon vorhanden).") { addProduct() }
//                            .multilineTextAlignment(.center)
//                            .padding()
//                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                    }
                    Spacer()
                }

//                Text("Status: \(self.offManager.state.description)").padding()
            }

            .navigationBarTitle("Open Food Facts")
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
        .onDisappear() {
            print("Scanning view onDisappear")
            self.offManager.reset()
        }
    }
    
    func addProduct() {
        
        if let product = offManager.offResponse?.product {

            // Check if product is already as food in local database
            if let food = Food.foodWithKey(key: product.code, inManagedObjectContext: viewContext) {
                food.updateFromOffProduct(product: product, inManagedObjectContext: viewContext)
//                currentMeal.meal.addIngredient(food: food, amount: NSNumber(0), managedObjectContext: viewContext)
                meal.addIngredient(food: food, amount: NSNumber(0), managedObjectContext: viewContext)
            } else {
                let food = Food.createFromOffProduct(product: product, inManagedObjectContext: viewContext)
//                currentMeal.meal.addIngredient(food: food, amount: NSNumber(0), managedObjectContext: viewContext)
                meal.addIngredient(food: food, amount: NSNumber(0), managedObjectContext: viewContext)
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



//struct ScanningView_Previews: PreviewProvider {
//    static var previews: some View {
//        OFFView(meal: meal)
//    }
//}

