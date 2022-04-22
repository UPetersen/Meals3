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
    @State private var isShowingDeleteAlert = false

    
    var body: some View {
        HStack {
            Button(action: { withAnimation {self.isShowingDeleteAlert = true} },
                   label: { Image(systemName: "trash").padding(.horizontal)
            })
                .alert(isPresented: $isShowingDeleteAlert){ self.deleteAlert() }

            Spacer()

            Button(action: { withAnimation{ self.createRecipeFromMeal() } },
                   label: { VStack { Text("Rezept"); Text("hieraus") }.font(.caption)
            })

            Spacer()

            NavigationLink(destination: GeneralSearchView(ingredientCollection: self.currentMeal.meal).environment(\.managedObjectContext, viewContext)) {
                Image(systemName: "magnifyingglass").padding(.horizontal)
            }

            Spacer()
            
            Button(action: { withAnimation{ self.copyMeal() } },
                   label: { Image(systemName: "doc.on.doc").padding(.horizontal)
            })

        }
        .padding(.bottom, 10)
    }

    func deleteAlert() -> Alert {
        print("delete the meal with confirmation")
        return Alert(title: Text("Mahlzeit wirklich löschen?"), message: Text(""),
              primaryButton: .destructive(Text("Delete")) {
                HealthManager.synchronize(self.currentMeal.meal, withSynchronisationMode: .delete)
                self.viewContext.delete(self.currentMeal.meal)
                self.currentMeal.meal = Meal.newestMeal(managedObjectContext: self.viewContext)
                try? self.viewContext.save()
                self.presentationMode.wrappedValue.dismiss()
            },
              secondaryButton: .cancel())
    }
    
    /// Create copy of this meal an dismiss the view
    func copyMeal() {
        debugPrint("Will copy the meal \(meal) and make it the new current meal")
        if let newMeal = Meal.fromMeal(meal, inManagedObjectContext: viewContext) {
            HealthManager.synchronize(newMeal, withSynchronisationMode: .store)
//            currentMeal.meal = Meal.newestMeal(managedObjectContext: viewContext)
            currentMeal.meal = currentMeal.meal.dateOfCreation! > newMeal.dateOfCreation! ? currentMeal.meal : newMeal // faster than looking in the database.
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