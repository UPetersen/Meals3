//
//  MealsNutrientsView.swift
//  Meals3
//
//  Created by Uwe Petersen on 10.11.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI


// Formatters only created once by putting them here

fileprivate let dateFormatter: DateFormatter = {
//    print("DateFormatter")
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

fileprivate let numberFormatter: NumberFormatter = {
//    print("numberFormatter")
    return NumberFormatter()
}()


/// Shows nutrient compremension data for a meal.
///
/// Example data is
///
/// `"11. Jan 2020 at 13:51"`
///
/// `"35 g KH  und 2 FPE"`
struct MealsNutrients: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var meal: Meal
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(meal.dateOfCreation ?? Date(), formatter: dateFormatter)")
                    .padding(.bottom, 4)
                Text("\(reducedNutrientString(meal: meal))")
            }
            .font(.headline)
            .padding(.vertical, 3)
            Spacer()
        }
//        .onAppear() {
//            print(self.meal.description)
//        }
    }
    
    func reducedNutrientString(meal: Meal?) -> String {
        if let meal = meal {
            let totalCarb    = Nutrient.dispStringForNutrientWithKey("totalCarb",    value: meal.doubleForKey("totalCarb"),    formatter: numberFormatter, inManagedObjectContext: viewContext) ?? ""
            var fpu = 0.0
            if let protein = meal.doubleForKey("totalProtein"), let fat = meal.doubleForKey("totalFat") {
                fpu = (9.0 * protein + 4.0 * fat) / 100.0 / 1000.0
            }
            return String("\(totalCarb) KH  und   \(numberFormatter.string(from: NSNumber(value: fpu)) ?? "") FPE")
        }
        return ""
    }
}




//#if DEBUG
struct MealNutrientsView_Previews: PreviewProvider {

    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
        return MealsNutrients(meal: Meal(context: context)).environment(\.managedObjectContext, context)

    }
}
//#endif
