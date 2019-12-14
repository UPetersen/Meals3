//
//  AddFoodView.swift
//  Meals3
//
//  Created by Uwe Petersen on 14.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct AddFoodView: View {
    @Environment(\.managedObjectContext) var viewContext
    var food: Food
    var meal: Meal
    @Binding var isPresented: Bool
    @State private var amount: NSNumber? = nil

    var body: some View {
        NavigationView() {
            Form {
                Section(header: Text("Lebensmittel hinzufügen")) {
                    VStack {
                        Text(food.name ?? "food without name")
                        HStack {
                            Text("Menge")
                            Spacer()
                            NSNumberTextField(label: "g", value: $amount, formatter: NumberFormatter())
                        }
                    }
                }
            }
            .onAppear() {
                print(self.meal.description)
            }
            .navigationBarTitle(Text("Hinzufügen"), displayMode: .inline)
            .navigationBarItems(
                leading:                     Button("Cancel") {
                    print("Cancel")
                    self.isPresented = false
                }.padding(),
                                trailing:
                Button("Add") {
                    print("Add")

                    self.isPresented = false
                }.padding()
            )
        }
    }
    
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let food: Food = {
            let food = Food(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            food.name = "leckerer Donut"
            food.comment = "Ein unnötiger Kommentar"
            food.totalCarb = 12.0
            food.totalFat = 23.0
            food.totalProtein = 14.0
            food.totalEnergyCals = 200.0
            food.totalAlcohol = 4.0
            food.totalWater = 55.0
            food.totalDietaryFiber = 32.0
            food.totalOrganicAcids = 0.4
            food.totalSalt = 0.3
            food.dateOfLastModification = Date()
            food.carbGlucose = 12.0
            
            return food
        }()
        
        let meal = Meal.newestMeal(managedObjectContext: context)
        

        return AddFoodView(food: food, meal: meal, isPresented: .constant(true))
            .environment(\.managedObjectContext, context)

    }
}
