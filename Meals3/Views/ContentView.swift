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
    @ObservedObject var search: SearchViewModel
    
    var body: some View {
        
        NavigationView {
            VStack{
                SearchBarView(searchText: self.$search.text)
                    .padding(.top, topMargin)
                
                MealsView(search: self.search)
                
                MealsViewToolbar()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle(Text("Mahlzeiten"), displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


// MARK: - Constants
let topMargin: CGFloat = 9


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let search = SearchViewModel()
        return ContentView(search: search).environment(\.managedObjectContext, context)
    }
}
