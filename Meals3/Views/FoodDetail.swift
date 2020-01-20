//
//  FoodDetail.swift
//  Meals3
//
//  Created by Uwe Petersen on 10.11.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData


fileprivate let numberFormatter: NumberFormatter =  {() -> NumberFormatter in
    let numberFormatter = NumberFormatter()
    numberFormatter.zeroSymbol = "0"
    numberFormatter.usesSignificantDigits = true
    return numberFormatter
}()

fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()


struct FoodDetail<T>: View where T: IngredientCollection {

    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var ingredientCollection: T
    @ObservedObject var food: Food
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var editingDisabled = true
    @State private var showingAddOrChangeAmountOfFoodView = false
    @State private var showingRecipeDetail = false
    @State private var showingDeleteFoodConfirmationAlert = false
    @State private var showingAllIngredients = false
    
    @FetchRequest(entity: Group.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Group.key, ascending: true)]) var groups: FetchedResults<Group>
    private var selectedGroup: Binding<Group?> {
        Binding<Group?> ( get: { self.food.group },
                          set: { newValue in self.food.group = newValue })
    }

    var fetchedSubGroups: [SubGroup]? {
        let request = NSFetchRequest<SubGroup>(entityName: "SubGroup")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SubGroup.key, ascending: true)]
        request.predicate = NSPredicate(format: "key contains %@", food.group?.key ?? "999")
        let fetchedSubGroups = try? viewContext.fetch(request)
        return fetchedSubGroups
    }
    private var selectedSubGroup: Binding<SubGroup?> {
        Binding<SubGroup?> ( get: { self.food.subGroup },
                             set: { newValue in self.food.subGroup = newValue })
    }

    var fetchedDetails: [Detail]? {
        let request = NSFetchRequest<Detail>(entityName: "Detail")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Detail.key, ascending: true)]
        request.predicate = NSPredicate(format: "subGroupKeysString contains %@", food.subGroup?.key ?? "999")
        let fetchedSubDetails = try? viewContext.fetch(request)
        return fetchedSubDetails
    }
    private var selectedDetail: Binding<Detail?> {
        Binding<Detail?> ( get: { self.food.detail },
                          set: { newValue in self.food.detail = newValue })
    }
//    @FetchRequest(entity: Detail.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Detail.key, ascending: true)]) var details: FetchedResults<Detail>

    
    var fetchedPreparations: [Preparation]? {
        let request = NSFetchRequest<Preparation>(entityName: "Preparation")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Preparation.key, ascending: true)]
        request.predicate = NSPredicate(format: "groupKeysString contains %@", food.group?.key ?? "999")
        let fetchedPreparations = try? viewContext.fetch(request)
        return fetchedPreparations
    }
    private var selectedPreparation: Binding<Preparation?> {
        Binding<Preparation?> ( get: { self.food.preparation },
                          set: { newValue in self.food.preparation = newValue })
    }

    @FetchRequest(entity: ReferenceWeight.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ReferenceWeight.key, ascending: true)]) var referenceWeight: FetchedResults<ReferenceWeight>
    private var selectedReferenceWeight: Binding<ReferenceWeight?> {
        Binding<ReferenceWeight?> ( get: { self.food.referenceWeight },
                          set: { newValue in self.food.referenceWeight = newValue })
    }

    
    
    var nutrientSections = NutrientSectionViewModel.sections()
    
    
    //    var editingDisabled: Bool = true
    private let noDate = Date(timeIntervalSince1970: 0)
    
    
    var body: some View {
        
        
        VStack {
            
            Form {

                Section {
                    Picker("Gruppe", selection: selectedGroup, content: {
                        Text("").tag(nil as Group?)
                        ForEach(self.groups) { (group: Group) in
                            Text("\(group.key ?? "") \(group.name ?? "")").tag(group as Group?)
                        }
                    })
                    if self.fetchedSubGroups != nil {
                        Picker("Untergruppe", selection: selectedSubGroup, content: {
                            Text("").tag(nil as SubGroup?)
                            ForEach(self.fetchedSubGroups!) { (subGroup: SubGroup) in
                                Text("\(subGroup.key ?? "") \(subGroup.name ?? "")").tag(subGroup as SubGroup?)
                            }
                        })
                    }
                    if self.fetchedDetails != nil {
                        Picker("Detail", selection: selectedDetail, content: {
                            Text("").tag(nil as Detail?)
                            ForEach(self.fetchedDetails!) { (detail: Detail) in
                                Text("\(detail.key ?? "") \(detail.name ?? "")").tag(detail as Detail?)
                            }
                        })
                    }
                    if self.fetchedPreparations != nil {
                        Picker("Zubereitung", selection: selectedPreparation, content: {
                            Text("").tag(nil as Preparation?)
                            ForEach(self.fetchedPreparations!) { (preparation: Preparation) in
                                Text("\(preparation.key ?? "") \(preparation.name ?? "")").tag(preparation as Preparation?)
                            }
                        })
                    }
                    Picker("Ref.-Gew.", selection: selectedReferenceWeight, content: {
                        Text("").tag(nil as ReferenceWeight?)
                        ForEach(self.referenceWeight) { (referenceWeight: ReferenceWeight) in
                            Text("\(referenceWeight.key ?? "") \(referenceWeight.name ?? "")").tag(referenceWeight as ReferenceWeight?)
                        }
                    })
                }

                // Section "Grundnährwerte je 100g"
                Section(header: Text(nutrientSections[0].header)) {
                    ForEach(nutrientSections[0].keys, id: \.self) { (key: String) in
                        return FoodNumberFieldWithKey(editingDisabled: self.$editingDisabled, food: self.food, key: key, numberFormatter: numberFormatter)
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
                }.lineLimit(nil)
                
                // Remaining sections, Button to ask user if he wants to see all nutrients
                if !showingAllIngredients {
                    HStack {
                        Spacer()
                        Button("Alle Nährwertdaten anzeigen") { self.showingAllIngredients = true }.padding()
                        Spacer()
                    }
                }
                if showingAllIngredients {
                    ForEach(nutrientSections.dropFirst()) {nutrientSection in
                        //          ForEach(nutrientSections.dropFirst(), id: \.self) {nutrientSection in
                        Section(header: Text(nutrientSection.header)) {
                            ForEach(nutrientSection.keys, id: \.self) { (key: String) in
                                return FoodNumberFieldWithKey(editingDisabled: self.$editingDisabled, food: self.food, key: key, numberFormatter: numberFormatter)
                            }
                        }
                    }
                }
            } // Form
                .onTapGesture(count: 2) {
                    self.showingAddOrChangeAmountOfFoodView = true
            }
            .environment(\.defaultMinListRowHeight, 1)

            FoodDetailToolbar(food: food, ingredientCollection: ingredientCollection)
            
            // Hidden NavigationLink with EmptyView() as label to move to FoodDetalsView with newly created Food, must be in if clause!
            if self.showingRecipeDetail && self.food.recipe != nil {
                NavigationLink(destination: RecipeDetail(recipe: self.food.recipe!), isActive: self.$showingRecipeDetail, label: { EmptyView() })
                        .hidden()
            }

            
        } // VStack
//            .onAppear() {
//                print(self.food.detail ?? "detail")
//                print(self.food.group ?? "group")
//                print(self.food.subGroup ?? "subGroup")
//                print(self.food.referenceWeight ?? "referenceWeight")
//                print(self.food.preparation ?? "preparation")
//        }
            
        .onDisappear() {
            print("foodDetail disappears")
            if self.viewContext.hasChanges {
                self.food.dateOfLastModification = Date()
                try? self.viewContext.save()            
            }
        }
        .navigationBarHidden(false)
        .navigationBarItems(trailing:
            HStack {
                Button(action: {
                    self.showingDeleteFoodConfirmationAlert = true
                }) {
                    Image(systemName: "trash").padding(.horizontal)
                }
                .alert(isPresented: $showingDeleteFoodConfirmationAlert){ deleteFoodConfirmationAlert() }

                Button(self.editingDisabled ? "Edit" : "Done") {
                    if self.food.recipe != nil {
                        self.showingRecipeDetail = true
                    } else {
                        self.editingDisabled.toggle()  // edit food data
                    }
                }.padding()
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
    
    func deleteFoodConfirmationAlert() -> Alert {
        return Alert(title: Text("Lebensmittel löschen?"), message: Text(self.food.deletionConfirmation()),
                     primaryButton: .destructive(Text("Löschen")) {
                        self.deleteFood()
            },
                     secondaryButton: .cancel())
    }
    
    func deleteFood() {
        food.managedObjectContext?.delete(food)
        try? self.viewContext.save()
        self.showingDeleteFoodConfirmationAlert = false
        self.presentationMode.wrappedValue.dismiss()
    }
    

    
    
    
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
