//
//  MealDetailView.swift
//  Meals3
//
//  Created by Uwe Petersen on 29.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()



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
            
            MealDetailViewToolbar().environmentObject(meal)
        }
        .navigationBarTitle("Mahlzeit-Details")
        .navigationBarItems(trailing: EditButton())
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
        return aFormatter.string(from: date)
    }
    
    
}



//struct MealDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailView()
//    }
//}
