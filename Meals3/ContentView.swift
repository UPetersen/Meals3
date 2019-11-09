//
//  ContentView.swift
//  Meals3
//
//  Created by Uwe Petersen on 31.10.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI
import CoreData

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var searchText = ""
 
    var body: some View {



        NavigationView {
            
            VStack {
                
                // Search view
                SearchBarView(searchText: $searchText)
                
                MealsView(searchText: $searchText)
                    .navigationBarTitle(Text("Master"))
                    .navigationBarItems(
                        leading: EditButton(),
                        trailing: Button(
                            action: {
                                withAnimation {
                                    Event.create(in: self.viewContext)
                                    // Create a new Meal
                                    let _ = Meal(context: self.viewContext)
                                    try? self.viewContext.save()
                                    //                                HealthManager.synchronize(meal, withSynchronisationMode: .save)
                                }
                        }
                        ) {
                            Image(systemName: "plus")
                        }
                )
                Text("Detail view content goes here")
                    .navigationBarTitle(Text("Detail"))
            }.navigationViewStyle(DoubleColumnNavigationViewStyle())
            
        }
    }
}

struct MealsView: View {
    
    @Environment(\.managedObjectContext) var viewContext

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Meal.dateOfCreation, ascending: false)],
//        animation: .default)
//    var mealsss: FetchedResults<Meal>
            
//    @FetchRequest(
//        fetchRequest: {
//            let request = NSFetchRequest<Meal>(entityName: "Meal")
//            request.fetchBatchSize = 1000
//            request.fetchLimit = 1000  // Speeds up a lot, especially inital loading of this view controller, but needs care
//            request.returnsObjectsAsFaults = true   // objects are only loaded, when needed/used -> faster but more frequent disk reads
//            request.includesPropertyValues = true   // usefull only, when only relevant properties are read
//            request.propertiesToFetch = ["dateOfCreation"] // read only certain properties (others are fetched automatically on demand)
//            request.relationshipKeyPathsForPrefetching = ["ingredients", "food"]
//            request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.dateOfCreation, ascending: false)]
//            return request
//        }(),
//        animation: .default)
//    var meals: FetchedResults<Meal>
    
    @Binding var searchText: String
    @FetchRequest var meals: FetchedResults<Meal>
    init(searchText: Binding<String>) {
        
        let searchFilter = SearchFilter.BeginsWith
        self._searchText = searchText
        
        let request = NSFetchRequest<Meal>(entityName: "Meal")
        request.predicate = searchFilter.predicateForMealsWithIngredientsWithSearchText(searchText.wrappedValue)
        request.fetchBatchSize = 50
        request.fetchLimit = 50  // Speeds up a lot, especially inital loading of this view controller, but needs care
        request.returnsObjectsAsFaults = true   // objects are only loaded, when needed/used -> faster but more frequent disk reads
        request.includesPropertyValues = true   // usefull only, when only relevant properties are read
        request.propertiesToFetch = ["dateOfCreation"] // read only certain properties (others are fetched automatically on demand)
        request.relationshipKeyPathsForPrefetching = ["ingredients", "food"]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.dateOfCreation, ascending: false)]
        self._meals = FetchRequest(fetchRequest: request)
    }


    var body: some View {
        List {
            ForEach(meals, id: \.self) { (meal: Meal) in

                Section(header:
                    VStack {
                        Text("\(meal.dateOfCreation!, formatter: dateFormatter)")
                        Text(self.mealNutrientsString(meal: meal))
                            .font(.footnote)
                            .lineLimit(1)
                    }
                ) {
                    
                    NavigationLink(
                        destination: MealDetailView(meal: meal)
                    ) {
                        VStack {
                            Text("\(meal.dateOfCreation!, formatter: dateFormatter)")
                            Text(self.mealNutrientsString(meal: meal))
                                .font(.footnote)
                                .lineLimit(1)
                        }
                    }

                    ForEach(meal.filteredAndSortedMealIngredients()!, id: \.self) { (mealIngredient: MealIngredient) in
                        MealIngredientCellView(mealIngredient: mealIngredient)
                    }
                }
            }
            .onDelete { indices in
                print("onDelete")
                self.meals.delete(at: indices, from: self.viewContext)
            }
            .onMove(perform: self.move)
        }
    
    }
    func move (from source: IndexSet, to destination: Int) {
        print("From: \(source.indices.endIndex.description)")
        print("To: \(destination)")
    }
    
     var calsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        numberFormatter.zeroSymbol = "0"
        return numberFormatter
    }()
    
     var zeroMaxDigitsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        numberFormatter.zeroSymbol = "0"
        return numberFormatter
    }()
    

     func mealNutrientsString(meal: Meal?) -> String {
        if let meal = meal {
            let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: meal.doubleForKey("totalEnergyCals"), formatter: calsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: meal.doubleForKey("totalCarb"),    formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: meal.doubleForKey("totalProtein"), formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: meal.doubleForKey("totalFat"),     formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: meal.doubleForKey("carbFructose"), formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            let carbGlucose   = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: meal.doubleForKey("carbGlucose"),  formatter: zeroMaxDigitsNumberFormatter, inManagedObjectContext: viewContext) ?? ""
            var totalAmount = ""
            if let amount = meal.amount {
                totalAmount = zeroMaxDigitsNumberFormatter.string(from: amount) ?? ""
            }
            return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " F, " + carbGlucose + " G, " + totalAmount + " g insg."
        }
        return ""
    }

    
}

struct MealIngredientCellView: View {
    @Environment(\.managedObjectContext) var viewContext
    var mealIngredient: MealIngredient
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(mealIngredient.food?.name ?? "-")
                    .lineLimit(1)
                Spacer()
                Text("\(mealIngredient.amount ?? NSNumber(-999), formatter: NumberFormatter()) g")
            }
            Text(self.contentFor(mealIngredient: mealIngredient))
                .lineLimit(1)
                .font(.footnote)
        }
    }
    
    func stringForNumber (_ number: NSNumber, formatter: NumberFormatter, divisor: Double) -> String {
        return (formatter.string(from: NSNumber(value: number.doubleValue / divisor)) ?? "nan")
    }
    
    func contentFor(mealIngredient: MealIngredient) -> String { // Returns a String like "44 kcal, 10 g, KH, ..."
        //        let formatter = oneMaxDigitsNumberFormatter
        let formatter = NumberFormatter()
        
        let totalEnergyCals = Nutrient.dispStringForNutrientWithKey("totalEnergyCals", value: mealIngredient.doubleForKey("totalEnergyCals"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: mealIngredient.doubleForKey("totalCarb"),    formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalProtein = Nutrient.dispStringForNutrientWithKey("totalProtein", value: mealIngredient.doubleForKey("totalProtein"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let totalFat     = Nutrient.dispStringForNutrientWithKey("totalFat",     value: mealIngredient.doubleForKey("totalFat"),     formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let carbFructose = Nutrient.dispStringForNutrientWithKey("carbFructose", value: mealIngredient.doubleForKey("carbFructose"), formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        let carbGlucose  = Nutrient.dispStringForNutrientWithKey("carbGlucose", value: mealIngredient.doubleForKey("carbGlucose"),  formatter: formatter, inManagedObjectContext: viewContext) ?? ""
        
        return totalEnergyCals + ", " + totalCarb + " KH, " + totalProtein + " Prot., " + totalFat + " Fett, " + carbFructose + " Fruct., " + carbGlucose + " Gluc."
    }
}



struct MealDetailView: View {
    @ObservedObject var meal: Meal
    @State private var birthDate: Date = Date()

    var body: some View {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let date = Binding<Date>(
            get: {self.meal.dateOfCreation ?? Date()},
            set: {self.meal.dateOfCreation = $0}
        )
                
        return VStack {
            Text("\(meal.dateOfCreation ?? Date(), formatter: dateFormatter)")
            Text(dateString(date: meal.dateOfCreation))
            
            DatePicker("", selection: date)
            Divider()
      
            Text("Meal has \(meal.ingredients?.count ?? 0) ingredients:")

            MealIngredientsView(meal: meal)

            Text("Comment")
            Text("this shall be the comment")
        }
        .navigationBarTitle("Mahlzeit-Details")
        .onDisappear(){
            try? self.meal.managedObjectContext?.save()
        }
    }
    
    
    func dateString(date: Date?) -> String {
        guard let date = date else { return "no date avaiable" }
        
        let aFormatter = DateFormatter()
        aFormatter.timeStyle = .short
        aFormatter.dateStyle = .full
        aFormatter.doesRelativeDateFormatting = true // "E.g. yesterday
//        aFormatter.locale = Locale(identifier: "de_DE")
        print("aFormatter: \(aFormatter.string(from: date))")
        return aFormatter.string(from: date)
    }
    
    
}

struct MealIngredientsView: View {
    @ObservedObject var meal: Meal

    var body: some View {
        return List {
            if meal.filteredAndSortedMealIngredients() == nil {
                Text("Leere Mahlzeit").foregroundColor(Color(.placeholderText))
            } else {
                ForEach(meal.filteredAndSortedMealIngredients()!, id: \.self) { (mealIngredient: MealIngredient) in
                    MealIngredientCellView(mealIngredient: mealIngredient)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
