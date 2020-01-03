//
//  MealDetailViewToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 29.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct MealDetailViewToolbar: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentMeal: CurrentMeal

    @State private var isShowingGeneralSearchView = false
    @State private var isShowingDeleteAlert = false

    
    var body: some View {
        HStack {
            Button(action: { withAnimation{print("book")} },
                   label: { Image(systemName: "book").padding(.horizontal)
            })

            Spacer()
            
            Button(action: { withAnimation{self.isShowingGeneralSearchView = true} },
                   label: { Image(systemName: "magnifyingglass").padding(.horizontal)
            })

            Spacer()
            
            Button(action: { withAnimation {self.isShowingDeleteAlert = true} },
                   label: { Image(systemName: "trash").padding(.horizontal)
            })
                .alert(isPresented: $isShowingDeleteAlert){ self.deleteAlert() }

            
            // Zero size (thus invisible) NavigationLink with EmptyView() to move to
            NavigationLink(destination: GeneralSearchView(ingredientCollection: self.currentMeal.meal),
                           isActive: $isShowingGeneralSearchView,
                           label: {EmptyView()})
                .frame(width: 0, height: 0)
        }
        .padding()
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
}

struct MealDetailViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        MealDetailViewToolbar()
    }
}
