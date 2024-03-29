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


struct FoodDetailView<T>: View where T: IngredientCollection {

    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var ingredientCollection: T
    @ObservedObject var food: Food
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var editingDisabled = true
    @State private var showingAddOrChangeAmountOfFoodView = false
    @State private var showingRecipeDetail = false
    @State private var showingDeleteFoodConfirmationAlert = false
    @State private var showingAllIngredients = false
    
    @FetchRequest(entity: Meals3.Group.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Meals3.Group.key, ascending: true)]) var groups: FetchedResults<Meals3.Group>
    private var selectedGroup: Binding<Meals3.Group?> { Binding<Meals3.Group?> (
            get: { food.group },
            set: { newValue in food.group = newValue
            })
    }

    var fetchedSubGroups: [SubGroup]? {
        let request = NSFetchRequest<SubGroup>(entityName: "SubGroup")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SubGroup.key, ascending: true)]
        request.predicate = NSPredicate(format: "key contains %@", food.group?.key ?? "999")
        let fetchedSubGroups = try? viewContext.fetch(request)
        return fetchedSubGroups
    }
    private var selectedSubGroup: Binding<SubGroup?> {
        Binding<SubGroup?> ( get: { food.subGroup },
                             set: { newValue in food.subGroup = newValue })
    }

    var fetchedDetails: [Detail]? {
        let request = NSFetchRequest<Detail>(entityName: "Detail")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Detail.key, ascending: true)]
        request.predicate = NSPredicate(format: "subGroupKeysString contains %@", food.subGroup?.key ?? "999")
        let fetchedSubDetails = try? viewContext.fetch(request)
        return fetchedSubDetails
    }
    private var selectedDetail: Binding<Detail?> {
        Binding<Detail?> ( get: { food.detail },
                          set: { newValue in food.detail = newValue })
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
        Binding<Preparation?> ( get: { food.preparation },
                          set: { newValue in food.preparation = newValue })
    }

    @FetchRequest(entity: ReferenceWeight.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ReferenceWeight.key, ascending: true)]) var referenceWeight: FetchedResults<ReferenceWeight>
    private var selectedReferenceWeight: Binding<ReferenceWeight?> {
        Binding<ReferenceWeight?> ( get: { food.referenceWeight },
                          set: { newValue in food.referenceWeight = newValue })
    }

    
    var nutrientSections = NutrientSectionViewModel.sections()
    
    
    //    var editingDisabled: Bool = true
    private let noDate = Date(timeIntervalSince1970: 0)
    
    
    var body: some View {
        
        VStack {
            
            Form {
                
                // Section Name und Quick Picks
                Section(header: Text(" ")) {
                    Text("\(food.name ?? "überhaupt kein Name bekannt")")
                }

                Section() {
                    if let nutrientDistributionBarChartData = food.nutrientDistributionBarChartData() {
                        NutrientsDistributionBarChart(stackedBarNutrientData: nutrientDistributionBarChartData)
                    }
                }
                
                // Section "Grundnährwerte je 100g"
                Section(header: Text(nutrientSections[0].header)) {
                    ForEach(nutrientSections[0].keys, id: \.self) { (key: String) in
                        return FoodNumberTextFieldWithKey(editingDisabled: $editingDisabled, food: food, key: key, numberFormatter: numberFormatter)
                    }
                }
                
                // Section "Allgemeine Informationen
                Section(header: Text("ALLGEMEINE INFORMATIONEN")) {

                    FoodNutritionStringView(text: "Name", value: $food.name, editingDisabled: $editingDisabled)

                    Picker("Gruppe", selection: selectedGroup, content: {
                        Text("").tag(nil as Meals3.Group?)
                        ForEach(groups) { (group: Meals3.Group) in
                            Text("\(group.key ?? "") \(group.name ?? "")").tag(group as Meals3.Group?)
                        }
                    })
                        .disabled(editingDisabled)
                    if fetchedSubGroups != nil {
                        Picker("Untergr.", selection: selectedSubGroup, content: {
                            Text("").tag(nil as SubGroup?)
                            ForEach(fetchedSubGroups!) { (subGroup: SubGroup) in
                                Text("\(subGroup.key ?? "") \(subGroup.name ?? "")").tag(subGroup as SubGroup?)
                            }
                        })
                            .disabled(editingDisabled)
                    }
                    if fetchedDetails != nil {
                        Picker("Detail", selection: selectedDetail, content: {
                            Text("").tag(nil as Detail?)
                            ForEach(fetchedDetails!) { (detail: Detail) in
                                Text("\(detail.key ?? "") \(detail.name ?? "")").tag(detail as Detail?)
                            }
                        })
                            .disabled(editingDisabled)
                    }
                    if fetchedPreparations != nil {
                        Picker("Zuber.", selection: selectedPreparation, content: {
                            Text("").tag(nil as Preparation?)
                            ForEach(fetchedPreparations!) { (preparation: Preparation) in
                                Text("\(preparation.key ?? "") \(preparation.name ?? "")").tag(preparation as Preparation?)
                            }
                        })
                            .disabled(editingDisabled)
                    }
                    Picker("Ref.-Gew.", selection: selectedReferenceWeight, content: {
                        Text("").tag(nil as ReferenceWeight?)
                        ForEach(referenceWeight) { (referenceWeight: ReferenceWeight) in
                            Text("\(referenceWeight.key ?? "") \(referenceWeight.name ?? "")").tag(referenceWeight as ReferenceWeight?)
                        }
                    })
                        .disabled(editingDisabled)

                    SwiftUI.Group() { // Group, because more than 10 elements otherwhise
                        HStack {
                            Text("Quelle")
                            Spacer()
                            Text(food.source?.name ?? "")
                        }
                        HStack {
                            Text("Marke")
                            Spacer()
                            Text(food.brand?.name ?? "")
                        }
                        HStack {
                            Text("Rezept")
                            Spacer()
                            if food.recipe?.dateOfCreation != nil {
                                Text("ja")
                            } else {
                                Text("nein")
                            }
                        }
                        DatePicker("Erstellt", selection: .constant(food.dateOfCreation ?? noDate)).disabled(editingDisabled)
                        HStack {
                            Text("Kommentar")
                            Spacer()
                            Text(food.comment ?? "")
                        }
                        DatePicker("Letzte Änderung", selection: .constant(food.dateOfLastModification ?? noDate)).disabled(true)
                        HStack {
                            //
                            if food.source?.name == "world.openfoodfacts.org" {
                                Text("EAN-Code")
                                Spacer()
                                Button(food.key ?? "") {
                                    UIApplication.shared.open(URL(string: "https://world.openfoodfacts.org/product/" + (food.key ?? ""))!, options: [:], completionHandler: nil)
                                }
                            } else {
                                Text("Key")
                                Spacer()
                                Text(food.key ?? "")
                            }
                        }
                    }
                }.lineLimit(nil)
                
                // Remaining sections, Button to ask user if he wants to see all nutrients
                if !showingAllIngredients {
                    HStack {
                        Spacer()
                        Button("Alle Nährwertdaten anzeigen") { showingAllIngredients = true }.padding()
                        Spacer()
                    }
                }
                if showingAllIngredients {
                    ForEach(nutrientSections.dropFirst()) {nutrientSection in
                        //          ForEach(nutrientSections.dropFirst(), id: \.self) {nutrientSection in
                        Section(header: Text(nutrientSection.header)) {
                            ForEach(nutrientSection.keys, id: \.self) { (key: String) in
                                return FoodNumberTextFieldWithKey(editingDisabled: $editingDisabled, food: food, key: key, numberFormatter: numberFormatter)
                            }
                        }
                    }
                }
            } // Form
            .onTapGesture(count: 2) {
                showingAddOrChangeAmountOfFoodView = true
            }
            .environment(\.defaultMinListRowHeight, 1)
            
            FoodDetailViewToolbar(food: food, ingredientCollection: ingredientCollection, showingAddOrChangeAmountOfFoodView: $showingAddOrChangeAmountOfFoodView)
            
            // Hidden NavigationLink with EmptyView() as label to move to FoodDetalsView with newly created Food, must be in if clause!
            if showingRecipeDetail && food.recipe != nil {
                NavigationLink(destination: RecipeDetailView(recipe: food.recipe!), isActive: $showingRecipeDetail, label: { EmptyView() })
                    .hidden()
            }
        } // VStack
        .navigationBarHidden(false)
        .navigationBarTitle(food.recipe == nil ? "Lebensmittel" : "Rezept")
        .toolbar() {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { showingDeleteFoodConfirmationAlert = true }) {
                    Image(systemName: "trash").padding(.horizontal)
                }
                .alert(isPresented: $showingDeleteFoodConfirmationAlert){ deleteFoodConfirmationAlert() }
                
                Button(editingDisabled ? "Edit" : "Done") {
                    if food.recipe != nil {
                        showingRecipeDetail = true
                    } else {
                        editingDisabled.toggle()  // edit food data
                        food.dateOfLastModification = Date()
                    }
                }.padding()
            }
        }
        .sheet(isPresented: $showingAddOrChangeAmountOfFoodView,
               onDismiss: { presentationMode.wrappedValue.dismiss() }) {
            AddOrChangeAmountOfIngredientView(food: food,
                                              task: .addAmountOfFoodToIngredientCollection(ingredientCollection),
                                              isPresented: $showingAddOrChangeAmountOfFoodView,
                                              presentationModeOfParentView: presentationMode)
        }
    } // body
    
    
    func deleteFoodConfirmationAlert() -> Alert {
        return Alert(title: Text("Lebensmittel löschen?"), message: Text(food.deletionConfirmation()),
                     primaryButton: .destructive(Text("Löschen")) {
                        deleteFood()
            },
                     secondaryButton: .cancel())
    }
    
    func deleteFood() {
        food.managedObjectContext?.delete(food)
        try? viewContext.save()
        showingDeleteFoodConfirmationAlert = false
        presentationMode.wrappedValue.dismiss()
    }
}



//struct FoodDetail_Previews: PreviewProvider {
//    
//    static var previews: some View {
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
//        let _: Nutrient? = { // Store a nutrient in core data
//            let nutrient = Nutrient(context: context)
//            nutrient.dispUnit = "g"
//            nutrient.key = "totalEnergyCals"
//            nutrient.name = "Energie (Teststring)"
//            //            try? context.save()
//            return nutrient
//        }()
//        
//        SwiftUI.Group {
//            SwiftUI.Group {
//                NavigationView {
//                    FoodDetailView(ingredientCollection: Meal.newestMeal(managedObjectContext: context), food: food)
//                        .environment(\.managedObjectContext, context)
//                        .navigationBarTitle(food.name ?? "Lebensmittel")
//                }
//                .previewDevice(PreviewDevice(rawValue: "iPhone 6S Plus"))
//                .previewDisplayName("iPhone 6S Plus")
//            }
//            
//            SwiftUI.Group {
//                NavigationView {
//                    FoodDetailView(ingredientCollection: Meal.newestMeal(managedObjectContext: context), food: food)
//                        .environment(\.managedObjectContext, context)
//                        .navigationBarTitle(food.name ?? "Lebensmittel")
//                }
//                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
//                .previewDisplayName("iPhone 13 Pro")
//            }
//
//            SwiftUI.Group {
//                NavigationView {
//                    FoodDetailView(ingredientCollection: Meal.newestMeal(managedObjectContext: context), food: food)
//                        .environment(\.managedObjectContext, context)
//                        .navigationBarTitle(food.name ?? "Lebensmittel")
//                }
//                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
//                .previewDisplayName("iPhone 13 Pro Max")
//            }
//        }
//        .previewInterfaceOrientation(.portrait)
//    }
//}
