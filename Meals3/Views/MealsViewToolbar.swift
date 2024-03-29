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

struct MealsViewToolbar: View {
    
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
            Button(action: { showingMenu.toggle()} ,
                   label: { Image(systemName: "ellipsis.circle").padding(.horizontal) })
                .actionSheet(isPresented: $showingMenu) { menuActionSheet() }  // Menu Action Sheet
                .alert(isPresented: $isPresentingHealthAuthorizationConfirmationAlert, content: authorizeHealthAlert)

            Spacer()

            NavigationLink(destination: GeneralSearchView(ingredientCollection: currentMeal.meal).environment(\.managedObjectContext, viewContext)) {
                Image(systemName: "magnifyingglass").padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: { isPresentingScanner = true }) {
                Image(systemName: "barcode.viewfinder").padding(.horizontal)
            }
            .sheet(isPresented: $isPresentingScanner) {
                OFFView(meal: currentMeal.meal)
            }
            
            Spacer()
            
            Button(action: { withAnimation {createNewMeal()} },
                   label: { Image(systemName: "plus").padding(.horizontal) })
        }
        .padding()
    }
    
    func menuActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Es ist angerichtet."), message: nil, buttons: [
            .default(Text("Neues Lebensmittel"))         { createNewFood() },
            .default(Text("Neues Rezept"))               { createNewRecipe() },
            .default(Text("Neue Mahlzeit"))              { createNewMeal() },
            .default(Text("Authorisiere Healthkit"))     { authorizeHealthKit() },
//            .default(Text("Copy all meals to HealthKit")){ copyMealsToHealthKit() },
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
                healthKitIsAuthorized = true
            } else {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(String(describing: error))")
                }
                healthKitIsAuthorized = false
            }
        }
        isPresentingHealthAuthorizationConfirmationAlert = true
    }

//    func copyMealsToHealthKit() {
//        print("Copy Meals to Healthkit")
//        let meals = Meal.fetchAllMeals(managedObjectContext: viewContext)
//        HealthManager.synchronizeMeals(meals)
//    }


    func createNewFood() {
        try? viewContext.save()
        newFood = Food(context: viewContext)
        isPresentingNewFood = true
    }

    func createNewRecipe() {
        let recipe = Recipe(context: viewContext)
        recipe.food = Food.fromRecipe(recipe, inManagedObjectContext: viewContext)
        newFood = recipe.food
        isPresentingNewFood = true
        try? viewContext.save()
    }
    
    func createNewMeal() {
        let meal = Meal(context: viewContext)
        currentMeal.updateByComparisonTo(meal, viewContext: viewContext)
        try? viewContext.save()
        HealthManager.synchronize(meal, withSynchronisationMode: .store)
    }
    
}





struct MainViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        return NavigationView {
            return MealsViewToolbar()
                .environment(\.managedObjectContext, viewContext)
                .navigationBarTitle("Main view toolbar")
        }
    }
}
