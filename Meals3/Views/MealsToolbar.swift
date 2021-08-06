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

    @EnvironmentObject var currentMeal: CurrentMeal
        
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
            
            Button(action: { self.isPresentingScanner = true }) {
                Image(systemName: "barcode.viewfinder").padding(.horizontal)
            }
            .sheet(isPresented: $isPresentingScanner) {
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
