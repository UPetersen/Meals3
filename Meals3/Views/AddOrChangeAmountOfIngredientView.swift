//
//  AddFoodView.swift
//  Meals3
//
//  Created by Uwe Petersen on 14.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

fileprivate let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = 3
    numberFormatter.minimum = 0
    return numberFormatter
}()


struct AddOrChangeAmountOfIngredientView: View {
    @Environment(\.managedObjectContext) var viewContext
    var food: Food
    var task: AddOrChangeTask
    @Binding var isPresented: Bool
    @Binding var presentationModeOfParentView: PresentationMode

    @State private var amount: NSNumber? = nil
    
    private var amountBinding: Binding<String> {
        Binding<String> (
            get: { self.amount.map{ numberFormatter.string(from: $0) ?? "" } ?? "" },
            set: { self.amount = numberFormatter.number(from: $0) }
        )
    }

    @State var title = "Menge hinzufügen" // "Menge hinzufügen" for new food or "Menge ändern" for updating the amount of a food
    
    var body: some View {
        
        NavigationView() {
            GeometryReader() { geometry in
                
                Form {
                    Section() {
                        Text(self.food.name ?? " ")
                    }
                    
                    Section(header: Text("Menge in der Mahlzeit"), footer: Text(" ")) {
                        HStack {
                            Spacer()
                            TextField("g", text: self.amountBinding)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .scaledToFit()
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }

                    Section() {
                        ZStack {
                            IPodStyleRotationWheel(amount: $amount)
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8, alignment: .center)
                                .onTapGesture { self.save() } // Tapping anywhere saves.
                            
                            Button("Speichern", action:{ self.save() })
                                .padding()
                                .foregroundColor(Color(.systemBlue))
                        }
                    }
                }
            }
            .navigationBarTitle(Text(self.title), displayMode: .inline)
            .navigationBarItems(leading:
                                    Button("Abbrechen") { self.isPresented = false }.padding(),
                                trailing:
                                    Button("Speichern") { self.save() }.padding()
            )

        }
        .onAppear() {
            switch self.task {
            case .changeAmountOfIngredient(let ingredient):
                self.amount = ingredient.amount
                self.title = "Menge ändern"
                print("AddOrChangeamountOfIngredientView: in onAppear")
            default: break
            }
        }
    }
    
    
    
    
    // MARK: - Constants
    let circleScaleFactor: CGFloat = 0.8
    let arrowsScaleFactor: CGFloat = 0.6
    let arrowsAspectRatio: CGFloat = 0.85
    let verticalSpacing: CGFloat = 20
    
    
    func save() {
        if let amount = self.amount {
            switch task {
            case .addAmountOfFoodToIngredientCollection(let ingredientCollection):
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
//                        recipe.food?.updateNutrients(managedObjectContext: self.viewContext)
                        recipe.food?.updateNutrients(amount: .sumOfAmountsOfRecipeIngredients, managedObjectContext: self.viewContext)

                        try? self.viewContext.save()
                        self.isPresented = false // dismiss self
                        self.$presentationModeOfParentView.wrappedValue.dismiss() // dismiss parent view (food details), too
//                        print("Recipestuff")
//                        print(recipe.amount ?? "")
//                        print(recipe.amountOfAllIngredients)
                    }
            case .changeAmountOfIngredient(var ingredient):
                ingredient.amount = self.amount
                if let meal = (ingredient as? MealIngredient)?.meal {
                    meal.dateOfLastModification = Date()
                    HealthManager.synchronize(meal, withSynchronisationMode: .update)
                } else if let recipe = (ingredient as? RecipeIngredient)?.recipe {
                    recipe.objectWillChange.send()

                    recipe.dateOfLastModification = Date()
//                    recipe.food?.updateNutrients(managedObjectContext: viewContext)
                    recipe.food?.updateNutrients(amount: .sumOfAmountsOfRecipeIngredients, managedObjectContext: viewContext)
//                    recipe.objectWillChange.send()

//                    print("Recipestuff")
//                    print(recipe.amount ?? "")
//                    print(recipe.amountOfAllIngredients)
                }
                try? viewContext.save()
                isPresented = false // dismiss self
            }
        }
    }
    
    // MARK: - Constants
    
}


extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}



struct AddFoodView_Previews: PreviewProvider {
    
    
    // NOTE: This view must bbe previewed from its parent view "FoodDetail".
    //       This is due to that I did not manage to create a Binding to the environment var presentationMode (which is read only)
    
    @Environment(\.presentationMode) static var presentationMode: Binding<PresentationMode>

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
        
        return SwiftUI.Group {
            SwiftUI.Group {
                AddOrChangeAmountOfIngredientView(food: food,
                                                   task: .addAmountOfFoodToIngredientCollection(meal as IngredientCollection),
                                                   isPresented: .constant(true),
                                                   presentationModeOfParentView: presentationMode)
                    .environment(\.managedObjectContext, context)
                    .previewDevice(PreviewDevice(rawValue: "iPhone 6S Plus"))
                    .previewDisplayName("iPhone 6S Plus")
            }
            SwiftUI.Group {
                AddOrChangeAmountOfIngredientView(food: food,
                                                   task: .addAmountOfFoodToIngredientCollection(meal as IngredientCollection),
                                                   isPresented: .constant(true),
                                                   presentationModeOfParentView: presentationMode)
                    .environment(\.managedObjectContext, context)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
                .previewDisplayName("iPhone 13 Pro Max")
            }
            SwiftUI.Group {
                AddOrChangeAmountOfIngredientView(food: food,
                                                   task: .addAmountOfFoodToIngredientCollection(meal as IngredientCollection),
                                                   isPresented: .constant(true),
                                                   presentationModeOfParentView: presentationMode)
                    .environment(\.managedObjectContext, context)
                .previewDevice(PreviewDevice(rawValue: "iPhone 6 S"))
                .previewDisplayName("iPhone 6 S")
            }
        }

        
    }
}
