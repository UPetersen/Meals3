//
//  MealsToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 22.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData
import AVFoundation

struct MealsToolbar: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @State private var healthKitIsAuthorized: Bool = false
    @State private var showingMenu = false
    @State private var isPresentingHealthAuthorizationConfirmationAlert: Bool = false
    
    @State private var newFood: Food?
    @State private var isPresentingNewFood: Bool = false
    
    @State private var isPresentingScanner: Bool = false
    @State var scannedBarcode: String?
    
//    @State private var isPresentingOffProduct: Bool = false
//    // Displays the scanner sheet and returns (hopefully) the number as string of the bar code (ean code)
//    var scannerSheet : some View {
//        CodeScannerView(
//            codeTypes: [.ean13, .ean8],
//            completion: { result in
//                if case let .success(code) = result {
//                    self.scannedBarcode = code
////                    self.isPresentingScannerCodeAlert = true
//                    print("scanner found code \(code)")
//                } else {
//                    self.scannedBarcode = nil
//                    print("scanner did not find any code")
//                }
//                self.isPresentingScanner = false
//            }
//        ).onDisappear(perform: {
//            if self.scannedBarcode != nil {
//                self.isPresentingFouncdABarcodeAlert = true // Display Alert with found barcode
//                self.networkController.fetchProduct(code: self.scannedBarcode ?? "")
//            }
//        })
//    }
    

    @EnvironmentObject var currentMeal: CurrentMeal
    
//    @StateObject private var networkController = NetworkController()
    
    var body: some View {
        HStack {
            Button(action: { self.showingMenu.toggle()} ,
                   label: { Image(systemName: "ellipsis.circle").padding(.horizontal) })
                .actionSheet(isPresented: $showingMenu) { menuActionSheet() }  // Menu Action Sheet
                .alert(isPresented: $isPresentingHealthAuthorizationConfirmationAlert, content: self.authorizeHealthAlert)

            Spacer()

            NavigationLink(destination: GeneralSearch(ingredientCollection: self.currentMeal.meal).environment(\.managedObjectContext, viewContext)) {
                Image(systemName: "magnifyingglass").padding(.horizontal)
            }

            
            Spacer()
            Button("Scan Code") {
                self.isPresentingScanner = true
            }
            .sheet(isPresented: $isPresentingScanner) {
//                self.scannerSheet
                ScanningView()
            }
            
            Spacer()
            
            Button(action: { withAnimation {self.createNewMeal()} },
                   label: { Image(systemName: "plus").padding(.horizontal) })
        }
        .padding()
    }
    
    func menuActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Es ist angerichtet."), message: nil, buttons: [
            .default(Text("Neues Lebensmittel")){ self.createNewFood() },
            .default(Text("Neues Rezept")){ self.createNewRecipe() },
            .default(Text("Neue Mahlzeit")){ self.createNewMeal() },
            .default(Text("Authorisiere Healthkit")){ self.authorizeHealthKit() },
            .cancel(Text("Zurück"))
            ]
        )
    }
    
    
//    @ViewBuilder func newFoodDetail() -> some View {
//        if self.newFood != nil {
//            FoodDetail(ingredientCollection: self.currentMeal.meal, food: self.newFood!)
//                .environmentObject( Meal.newestMeal(managedObjectContext: self.viewContext))
//        }
//    }
//
//

    func authorizeHealthAlert() -> Alert {
        let text = healthKitIsAuthorized ? "Health wurde autorisiert." : "Health wurde nicht autorisiert."
        return Alert(title: Text(text), message: nil, dismissButton: .default(Text("Verstanden")) {})
    }

    func authorizeHealthKit() {
        print("Authorize Healthkit")
        HealthManager.authorizeHealthKit {(authorized, error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
                self.healthKitIsAuthorized = true
            } else {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(String(describing: error))")
                }
                self.healthKitIsAuthorized = false
            }
        }
        self.isPresentingHealthAuthorizationConfirmationAlert = true
    }

    
    func createNewFood() {
        try? self.viewContext.save()
        newFood = Food(context: viewContext)
        isPresentingNewFood = true
    }

    func createNewRecipe() {
        let recipe = Recipe(context: self.viewContext)
        recipe.food = Food.fromRecipe(recipe, inManagedObjectContext: self.viewContext)
        newFood = recipe.food
        isPresentingNewFood = true

        try? self.viewContext.save()
    }
    
    func createNewMeal() {
        let meal = Meal(context: viewContext)
        currentMeal.meal = meal
        try? viewContext.save()
        HealthManager.synchronize(meal, withSynchronisationMode: .save)
    }
    
}





struct MainViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        return NavigationView {
            return MealsToolbar()
                .environment(\.managedObjectContext, viewContext)
                .navigationBarTitle("Main view toolbar")
        }
    }
}





//struct OffResponseView: View {
//    let offResponse: OffResponse?
//    
//    var body: some View {
//        VStack(content: {
//            Text("Response code:")
//            Text(String(offResponse?.code ?? "kein code gefunden"))
//        })
//    }
//}



func testJson() {
    let json =     """
    {
       "status_verbose": "product found",
       "status": 1,
       "code": "04963406",
       "product": {
         "code": "04963406",
         "product_name": "Coca-Cola",
         "nutriments": {
           "fiber_value": 0,
           "carbohydrates_100g": 11,
           "carbohydrates_value": 39,
           "energy_unit": "kcal",
           "sodium": 0.045,
           "energy_serving": 586,
           "proteins": 0,
           "fruits-vegetables-nuts-estimate-from-ingredients_100g": 0,
           "salt": 0.1125,
           "salt_100g": 0.0317,
           "sugars_value": 39,
           "saturated-fat_value": 0,
           "proteins_unit": "g",
           "energy": 586,
           "nova-group_100g": 4,
           "salt_serving": 0.1125,
           "nutrition-score-fr_100g": 14,
           "nutrition-score-fr": 14,
           "fat_value": 0,
           "carbohydrates_unit": "g",
           "nova-group_serving": 4,
           "energy-kcal_value": 140,
           "energy-kcal_100g": 39.4,
           "fiber": 0,
           "sugars": 39,
           "fat_serving": 0,
           "proteins_value": 0,
           "nova-group": 4,
           "energy-kcal_serving": 140,
           "saturated-fat_unit": "g",
           "fat": 0,
           "energy-kcal_unit": "kcal",
           "proteins_100g": 0,
           "fiber_serving": 0,
           "energy_100g": 165,
           "energy-kcal": 140,
           "salt_value": 112.5,
           "sugars_unit": "g",
           "fiber_100g": 0,
           "proteins_serving": 0,
           "sugars_serving": 39,
           "sodium_unit": "mg",
           "salt_unit": "mg",
           "fat_unit": "g",
           "carbohydrates": 39,
           "sodium_100g": 0.0127,
           "saturated-fat": 0,
           "energy_value": 140,
           "fiber_unit": "g",
           "sodium_value": 45,
           "fat_100g": 0,
           "carbohydrates_serving": 39,
           "sodium_serving": 0.045,
           "sugars_100g": 11,
           "saturated-fat_serving": 0,
           "saturated-fat_100g": 0
         }
       }
     }
    """.data(using: .utf8)!


    // decoding stuff
    let decoder = JSONDecoder()
    let offResponse = try? decoder.decode(OffResponse.self, from: json)

    print("")
    print("Code: \(offResponse?.code)")
    print("Code: \(offResponse?.product.code ?? "no code")")
    print("Name: \(offResponse?.product.name ?? "no code")")
    print("totalEnergyCals: \(offResponse?.product.totalEnergyCals ?? -1)")
    print("totalCarbs:      \(offResponse?.product.totalCarbs ?? -1)")
    print("totalProtein:    \(offResponse?.product.totalProtein ?? -1)")
    print("totalFat:        \(offResponse?.product.totalFat ?? -1)")
}





