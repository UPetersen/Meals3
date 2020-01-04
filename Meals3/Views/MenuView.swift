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
    @Binding var showThisMenu: Bool
    @EnvironmentObject var currentMeal: CurrentMeal

    @State private var isPresentingNewFood: Bool = false
    @State private var isPresentingHealthAuthorizationConfirmationAlert: Bool = false
    @State private var healthKitIsAuthorized: Bool = false

    
    var body: some View {
        
        // small drag to remove menu
        let drag = DragGesture()
            .onEnded {
                if abs($0.translation.width) > 50 || abs($0.translation.height) > 50 {
                    withAnimation {
                        self.showThisMenu = false
                    }
                }
        }

        return VStack(alignment: .leading) {
            Text("Neues Lebensmittel")
                .padding()
                .onTapGesture {
                    try? self.viewContext.save()
                    self.isPresentingNewFood = true
            }
            .padding(.top, 70)
            
            Text("Neue Mahlzeit")
                .padding()
                .onTapGesture {
                    self.currentMeal.meal = Meal(context: self.viewContext) // Creates new meal and sets it to current meal
                    try? self.viewContext.save()
                    HealthManager.synchronize(self.currentMeal.meal, withSynchronisationMode: .save)
                    withAnimation { self.showThisMenu = false }
            }
            Text("Neues Rezept")
                .padding()
                .onTapGesture {
                    _ = Recipe(context: self.viewContext)
                    try? self.viewContext.save()
                    self.showThisMenu = false
            }
            Text("Authorize Healthkit")
                .padding()
                .onTapGesture {
                    print("Authorize Healthkit")
                    self.authorizeHealthKit()
                    self.isPresentingHealthAuthorizationConfirmationAlert = true
//                    self.showMenu = false
            }
            .alert(isPresented: $isPresentingHealthAuthorizationConfirmationAlert, content: self.authorizeHealthAlert)


            Spacer() // Expand screen to bottom
            
            // Hidden NavigationLink with EmptyView() as label to move to FoodDetalsView with newly created Food, must be in if clause!
            if self.isPresentingNewFood {
                    NavigationLink(destination: foodDetail(), isActive: self.$isPresentingNewFood, label: { EmptyView() })
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
                self.showThisMenu = false
            }
        }
    }
    
    func foodDetail() -> some View {
        return FoodDetail(ingredientCollection: self.currentMeal.meal,
                               food: Food(context: viewContext)
        )
            .environmentObject( Meal.newestMeal(managedObjectContext: self.viewContext))
            .onDisappear(){
                withAnimation(.easeOut(duration: 0.1)) {
                    self.showThisMenu = false
                }
        }
    }
    
    
    func authorizeHealthAlert() -> Alert {
        print("Authorize Health Alert")
        if self.healthKitIsAuthorized {
            return Alert(title: Text("Health wurde autorisiert."), message: nil,
                         dismissButton: .default(Text("Okay")) { self.showThisMenu = false })
        } else {
            return Alert(title: Text("Health wurde nicht autorisiert."), message: nil,
                         dismissButton: .destructive(Text("Okay")) {self.showThisMenu = false})
        }
    }

    func authorizeHealthKit() {
        HealthManager.authorizeHealthKit { (authorized,  error) -> Void in
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
    }
    
}




struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return MenuView(showThisMenu: .constant(true)).environment(\.managedObjectContext, viewContext)
    }
}
