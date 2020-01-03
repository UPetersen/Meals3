//
//  MealsViewToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 22.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData

struct MealsViewToolbar: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var isShowingGeneralSearchView = false
    
//    @EnvironmentObject var currentIngredientCollection: CurrentIngredientCollection
    @EnvironmentObject var currentMeal: CurrentMeal

    
    var body: some View {
        HStack {
            Button(action: { withAnimation{print("book")}},
                   label: { Image(systemName: "book").padding(.horizontal) })

            Spacer()
            
            Button(action: { withAnimation{self.isShowingGeneralSearchView = true} },
                   label: { Image(systemName: "magnifyingglass").padding(.horizontal) })

            Spacer()
            
            Button(action: { withAnimation {self.newMeal()} },
                   label: { Image(systemName: "plus").padding(.horizontal) })
            
            // Zero size (thus invisible) NavigationLink with EmptyView() to move to
            NavigationLink(destination: GeneralSearchView(ingredientCollection: self.currentMeal.meal),
                           isActive: $isShowingGeneralSearchView,
                           label: {EmptyView()})
                .frame(width: 0, height: 0)
        }
        .padding()
    }
    
    func newMeal() {
        let meal = Meal(context: self.viewContext)
        self.currentMeal.meal = meal
        try? self.viewContext.save()
//        HealthManager.synchronize(meal, withSynchronisationMode: .save)
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
