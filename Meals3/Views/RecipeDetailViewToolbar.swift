//
//  RecipeDetailToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 05.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct RecipeDetailViewToolbar: View {
    @ObservedObject var recipe: Recipe
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isShowingGeneralSearchView = false
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        HStack {
            Button(action: { withAnimation{ copyRecipe() } },
                   label: { Image(systemName: "doc.on.doc").padding(.horizontal)
            })

            Spacer()
            
            NavigationLink(destination: GeneralSearchView(ingredientCollection: recipe).environment(\.managedObjectContext, viewContext)) {
                Image(systemName: "magnifyingglass").padding(.horizontal)
            }

            Spacer()
            
            Button(action: { withAnimation {isShowingDeleteAlert = true} },
                   label: { Image(systemName: "trash").padding(.horizontal)
            })
                .alert(isPresented: $isShowingDeleteAlert){ deleteAlert() }
        }
        .padding()
    }

    func copyRecipe() {
        
    }
    
    func deleteAlert() -> Alert {
        print("delete the Recipe with confirmation")
        return Alert(title: Text("Rezept wirklich löschen?"), message: Text(recipe.food?.deletionConfirmation() ?? ""),
              primaryButton: .destructive(Text("Delete")) {
                presentationMode.wrappedValue.dismiss()
                viewContext.delete(recipe)
                try? viewContext.save()
            },
              secondaryButton: .cancel())
    }
}

//struct RecipeDetailToolbar_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeDetailToolbar()
//    }
//}
