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
    @ObservedObject var searchViewModel: SearchViewModel
    
    var body: some View {
        
//        NavigationStack {  /// BEWARE: navigationStack broke the possibility of editing recipes.
        NavigationView {
            VStack{
                SearchBarView(searchText: $searchViewModel.text)
                    .padding(.top, topMargin)
                MealsView(searchViewModel: searchViewModel)
                MealsViewToolbar()
            }
            .navigationBarTitle(Text("Mahlzeiten"), displayMode: .inline)
            .toolbar(content: {EditButton()})
//            .navigationBarItems(trailing: EditButton())
        }
        .navigationViewStyle(.stack)
    }
}


// MARK: - Constants
let topMargin: CGFloat = 9


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let searchViewModel = SearchViewModel()
        return ContentView(searchViewModel: searchViewModel).environment(\.managedObjectContext, context)
    }
}
