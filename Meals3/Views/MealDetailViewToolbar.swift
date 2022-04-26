//
//  MealDetailToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 29.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct MealDetailViewToolbar: View {
    @ObservedObject var meal: Meal

    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentMeal: CurrentMeal

    @State private var isShowingGeneralSearchView = false
    @State private var isPresentingScanner: Bool = false
    
    var body: some View {
        HStack {
            Button(action: { withAnimation{ createRecipeFromMeal() } }) {
                VStack { Text("Rezept"); Text("hieraus") }.font(.caption)
            }
            .padding(.leading)

            Spacer()

            NavigationLink(destination: GeneralSearchView(ingredientCollection: meal).environment(\.managedObjectContext, viewContext)) {
                Image(systemName: "magnifyingglass").padding(.horizontal)
            }

            Spacer()
            
            Button(action: { isPresentingScanner = true }) {
                Image(systemName: "barcode.viewfinder").padding(.horizontal)
            }
            .sheet(isPresented: $isPresentingScanner) {
                OFFView(meal: meal)
            }
            
            Spacer()
            
            Button(action: { withAnimation{ copyMeal() } },
                   label: { Image(systemName: "doc.on.doc").padding(.horizontal)
            })

        }
        .padding(.bottom, 10)
    }

    /// Create copy of this meal an dismiss the view
    func copyMeal() {
        debugPrint("Will copy the meal \(meal) and make it the new current meal")
        if let newMeal = Meal.fromMeal(meal, inManagedObjectContext: viewContext) {
            HealthManager.synchronize(newMeal, withSynchronisationMode: .store)
            currentMeal.updateByComparisonTo(newMeal, viewContext: viewContext)
            try? viewContext.save()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func createRecipeFromMeal() {
        presentationMode.wrappedValue.dismiss()
        _ = Recipe.fromMeal(meal, inManagedObjectContext: viewContext)
    }
}

//struct MealDetailViewToolbar_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailToolbar()
//    }
//}
