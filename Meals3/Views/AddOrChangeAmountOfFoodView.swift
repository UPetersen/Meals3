//
//  AddFoodView.swift
//  Meals3
//
//  Created by Uwe Petersen on 14.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

fileprivate let formatter: NumberFormatter = {
    return NumberFormatter()
    }()

struct AddOrChangeAmountOfFoodView: View {
    @Environment(\.managedObjectContext) var viewContext
    var food: Food
    var task: Task
    @Binding var isPresented: Bool
    @Binding var presentationModeOfParentView: PresentationMode

    @State private var amount: NSNumber? = nil

    var body: some View {
        NavigationView() {
            Form {
                Section(header: Text("Lebensmittel hinzufügen")) {
                    Text(food.name ?? "food without name")
                    HStack {
                        Text("Menge")
                        Spacer()
                        NSNumberTextField(label: "g", value: $amount, formatter: formatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                HStack {
                    Spacer()
                    Button("Übernehmen", action:{ self.save() })
                        .padding()
                    Spacer()
                }

            }
            .onAppear() {
                switch self.task {
                case .changeAmountOfIngredient(let ingredient):
                    self.amount = ingredient.amount
                default: break
                }
            }
            .navigationBarTitle(Text("Hinzufügen"), displayMode: .inline)
            .navigationBarItems(leading:
                Button("Cancel") { self.isPresented = false }.padding(),
                                trailing:
                Button("Save") {
                    self.save()
                }.padding()
            )

        }
        .onTapGesture(count: 2) {
            self.save()
        }

    }
    func save() {
        if let amount = self.amount {
            switch self.task {
            case .addAmountOfFoodToIngredientCollection(let ingredientCollection):
                DispatchQueue.main.async {
                    ingredientCollection.addIngredient(food: self.food, amount: amount, managedObjectContext: self.viewContext)
                    if let meal = ingredientCollection as? Meal {
                        meal.objectWillChange.send()
                        meal.dateOfLastModification = Date()
                        try? self.viewContext.save()
                        HealthManager.synchronize(meal, withSynchronisationMode: .update)
                        self.isPresented = false // dismiss self
                        self.$presentationModeOfParentView.wrappedValue.dismiss() // dismiss parent view (food details), too
                    } else if let recipe = ingredientCollection as? Recipe {
                        recipe.objectWillChange.send()
                        recipe.dateOfLastModification = Date()
                        recipe.food?.updateNutrients(managedObjectContext: self.viewContext)
                        try? self.viewContext.save()
                        self.isPresented = false // dismiss self
                        self.$presentationModeOfParentView.wrappedValue.dismiss() // dismiss parent view (food details), too
//                        print("Recipestuff")
//                        print(recipe.amount ?? "")
//                        print(recipe.amountOfAllIngredients)
                    }
                }
            case .changeAmountOfIngredient(var ingredient):
                ingredient.amount = self.amount
                if let meal = (ingredient as? MealIngredient)?.meal {
                    meal.dateOfLastModification = Date()
                    HealthManager.synchronize(meal, withSynchronisationMode: .update)
                } else if let recipe = (ingredient as? RecipeIngredient)?.recipe {
                    recipe.dateOfLastModification = Date()
                    recipe.food?.updateNutrients(managedObjectContext: self.viewContext)
//                    print("Recipestuff")
//                    print(recipe.amount ?? "")
//                    print(recipe.amountOfAllIngredients)
                }
                try? self.viewContext.save()
                self.isPresented = false // dismiss self
            }
        }
    }
    
}

//struct AddFoodView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        let food: Food = {
//            let food = Food(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
//            food.name = "leckerer Donut"
//            food.comment = "Ein unnötiger Kommentar"
//            food.totalCarb = 12.0
//            food.totalFat = 23.0
//            food.totalProtein = 14.0
//            food.totalEnergyCals = 200.0
//            food.totalAlcohol = 4.0
//            food.totalWater = 55.0
//            food.totalDietaryFiber = 32.0
//            food.totalOrganicAcids = 0.4
//            food.totalSalt = 0.3
//            food.dateOfLastModification = Date()
//            food.carbGlucose = 12.0
//
//            return food
//        }()
//
//        let meal = Meal.newestMeal(managedObjectContext: context)
//
//
//        return AddOrChangeAmountOfFoodView(food: food,
//                           task: Task.addAmountOfFoodToNutrientCollection(meal as NutrientCollection),
//                           isPresented: .constant(true))
//            .environment(\.managedObjectContext, context)
//
//    }
//}
