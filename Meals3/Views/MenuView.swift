//
//  MenuView.swift
//  Meals3
//
//  Created by Uwe Petersen on 19.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var showMenu: Bool
    @State private var isPresentingNewFood: Bool = false
    @EnvironmentObject var currentMeal: CurrentMeal
        
    var body: some View {
        
        // small drag to remove menu
        let drag = DragGesture()
            .onEnded {
                if abs($0.translation.width) > 50 || abs($0.translation.height) > 50 {
                    withAnimation {
                        self.showMenu = false
                    }
                }
        }

        return VStack(alignment: .leading) {
            Text("Neues Lebensmittel")
                .padding()
                .onTapGesture {
                    self.isPresentingNewFood = true
            }
            .padding(.top, 70)
            
            Text("Neue Mahlzeit")
                .padding()
                .onTapGesture {
                    self.currentMeal.meal = Meal(context: self.viewContext) // Creates new meal and sets it to current meal
                    withAnimation { self.showMenu = false }
            }
            Text("Neues Rezept")
                .padding()
                .onTapGesture {
                    _ = Recipe(context: self.viewContext)
                    self.showMenu = false
            }
            
            Spacer() // Expand screen to bottom
            
            // Hidden NavigationLink with EmptyView() as label to move to FoodDetalsView with newly created Food, must be in if clause!
            if self.isPresentingNewFood {
                    NavigationLink(destination: foodDetailsView(), isActive: self.$isPresentingNewFood, label: { EmptyView() })
                        .hidden()
            }
        }
        .font(.headline)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .edgesIgnoringSafeArea(.all)
        .background((Color(.systemBackground)))
        .shadow(color: Color(.secondarySystemBackground), radius: 6, x: 1, y: 1)
        .gesture(drag)
        .onTapGesture {
            withAnimation {
                self.showMenu = false
            }
        }
    }
    
    func foodDetailsView() -> some View {
        return FoodDetailsView(ingredientCollection: self.currentMeal.meal,
                               food: Food(context: viewContext)
        )
            .environmentObject( Meal.newestMeal(managedObjectContext: self.viewContext))
            .onDisappear(){
                withAnimation(.easeOut(duration: 0.1)) {
                    self.showMenu = false
                }
        }
    }
}




struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return MenuView(showMenu: .constant(true)).environment(\.managedObjectContext, viewContext)
    }
}
