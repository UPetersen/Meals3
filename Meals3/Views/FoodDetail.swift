//
//  FoodDetail.swift
//  Meals3
//
//  Created by Uwe Petersen on 10.11.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData

struct FoodDetail<T>: View where T: IngredientCollection {

    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var ingredientCollection: T
    @ObservedObject var food: Food
    
    @State private var editingDisabled = true
    @State private var showingAddOrChangeAmountOfFoodView = false
    @State private var showingRecipeDetail = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var nutrientSections = NutrientSectionViewModel.sections()
    
    let numberFormatter: NumberFormatter =  {() -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.zeroSymbol = "0"
        numberFormatter.usesSignificantDigits = true
        return numberFormatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    //    var editingDisabled: Bool = true
    private let noDate = Date(timeIntervalSince1970: 0)
    
    var body: some View {
        
        
        VStack {
            
            Form {
                // Section "Grundnährwerte je 100g"
                Section(header: Text(nutrientSections[0].header)) {
                    ForEach(nutrientSections[0].keys, id: \.self) { (key: String) in
                        return FoodNumberFieldWithKey(editingDisabled: self.$editingDisabled, food: self.food, key: key, numberFormatter: self.numberFormatter)
                    }
                }
                
                // Section "Allgemeine Informationen
                Section(header: Text("ALLGEMEINE INFORMATIONEN")) {
                    FoodNutritionString(text: "Name", value: $food.name, editingDisabled: $editingDisabled)
                    HStack {
                        Text("Detail")
                        Spacer()
                        Text(food.detail?.name ?? "")
                    }
                    HStack {
                        Text("Gruppe")
                        Spacer()
                        Text(food.group?.name ?? "")
                    }
                    HStack {
                        Text("Untergr.")
                        Spacer()
                        Text(food.subGroup?.name ?? "")
                    }
                    HStack {
                        Text("Zuber.")
                        Spacer()
                        Text(food.preparation?.name ?? "")
                    }
                    HStack {
                        Text("Refer.")
                        Spacer()
                        Text(food.referenceWeight?.name ?? "")
                    }
                    HStack {
                        Text("Quelle")
                        Spacer()
                        Text(food.source?.name ?? "")
                    }
                    HStack {
                        Text("Rezept")
                        Spacer()
                        if food.recipe?.dateOfCreation != nil {
                            Text("ja (\(food.recipe!.dateOfCreation!, formatter: dateFormatter))")
                        } else {
                            Text("nein")
                        }
                    }
                    DatePicker("Erstellt", selection: .constant(food.dateOfCreation ?? noDate)).disabled(editingDisabled)
                    DatePicker("Letzte Änderung", selection: .constant(food.dateOfLastModification ?? noDate)).disabled(true)
                }
                
                // Remaining sections
                ForEach(nutrientSections.dropFirst()) {nutrientSection in
                    //          ForEach(nutrientSections.dropFirst(), id: \.self) {nutrientSection in
                    Section(header: Text(nutrientSection.header)) {
                        ForEach(nutrientSection.keys, id: \.self) { (key: String) in
                            return FoodNumberFieldWithKey(editingDisabled: self.$editingDisabled, food: self.food, key: key, numberFormatter: self.numberFormatter)
                        }
                    }
                }
            } // Form
                .onTapGesture(count: 2) {
                    self.showingAddOrChangeAmountOfFoodView = true
            }
            .environment(\.defaultMinListRowHeight, 1)

            FoodDetailToolbar(food: food)
            
            // Hidden NavigationLink with EmptyView() as label to move to FoodDetalsView with newly created Food, must be in if clause!
            if self.showingRecipeDetail && self.food.recipe != nil {
                NavigationLink(destination: RecipeDetail(recipe: self.food.recipe!), isActive: self.$showingRecipeDetail, label: { EmptyView() })
                        .hidden()
            }

            
        } // VStack
            
        .onDisappear() {
            print("foodDetail disappears")
            if self.viewContext.hasChanges {
                self.food.dateOfLastModification = Date()
                try? self.viewContext.save()            
            }
        }
        .navigationBarHidden(false)
        .navigationBarItems(trailing: HStack {
            Button(self.editingDisabled ? "Edit" : "Done") {
                if self.food.recipe != nil {
                    self.showingRecipeDetail = true
                } else {
                    self.editingDisabled.toggle()  // edit food data
                }
            }.padding()
            Button(action: {
                print("Plus button was tapped")
                self.showingAddOrChangeAmountOfFoodView = true
            }) { Image(systemName: "plus").padding() }
        }
        .sheet(isPresented: $showingAddOrChangeAmountOfFoodView, content:{
            AddOrChangeAmountOfFoodView(food: self.food,
                                        task: .addAmountOfFoodToIngredientCollection(self.ingredientCollection),
                                        isPresented: self.$showingAddOrChangeAmountOfFoodView, presentationModeOfParentView: self.presentationMode)
                .environment(\.managedObjectContext, self.viewContext)}
            )
        )
            .navigationBarTitle(self.food.name ?? "no name given")
            .resignKeyboardOnDragGesture()
        
    } // body
}



struct FoodDetail_Previews: PreviewProvider {
    
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
        let _: Nutrient? = { // Store a nutrient in core data
            let nutrient = Nutrient(context: context)
            nutrient.dispUnit = "g"
            nutrient.key = "totalEnergyCals"
            nutrient.name = "Energie (Teststring)"
            //            try? context.save()
            return nutrient
        }()
        
        return NavigationView {
            FoodDetail(ingredientCollection: Meal.newestMeal(managedObjectContext: context), food: food)
                .environment(\.managedObjectContext, context)
                .navigationBarTitle(food.name ?? "Lebensmittel")
        }
        
    }
}
