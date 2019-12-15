//
//  ContentView.swift
//  Meals3
//
//  Created by Uwe Petersen on 31.10.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

// Look here, when adding a view to add the food to a meal. We then need a new sheet and take care of the managed object context:
// https://www.hackingwithswift.com/books/ios-swiftui/creating-books-with-core-data

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
                .resignKeyboardOnDragGesture()

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
//            .resignKeyboardOnDragGesture()

            
        }
    }
}

//struct MealsView: View {
//}


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
            
            Text("\(meal.dateOfLastModification ?? Date(), formatter: dateFormatter)")
            Text(dateString(date: meal.dateOfLastModification))

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
    
    func contentFor(mealIngredient: MealIngredient) -> String {
        // Returns a String like "44 kcal, 10 g, KH, ..."
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
