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
//    @EnvironmentObject var search: Search
    
    let oneMaxDigitsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
        print("in Numberformatter")
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        numberFormatter.zeroSymbol = "0"
        return numberFormatter
    }()

    @ObservedObject var search = Search()

    @State private var showMenu: Bool = false
    
    var body: some View {
                
        return NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .leading)  {
                    VStack{
                        SearchBarView(searchText: self.$search.text)
  
                        MealsView(search: self.search)

                        // Bottom tool bar
                        MealsViewToolbar()
                    }
                    .offset(x: self.showMenu ? geometry.size.width*0.4 : 0)
                    .disabled(self.showMenu ? true : false)
                    
                    if self.showMenu {
                        MenuView(showThisMenu: self.$showMenu)
                            .frame(width: geometry.size.width*0.6, height: geometry.size.height)
                            .transition(.move(edge: .leading))
//                            .gesture(drag)
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
//            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .navigationBarTitle(Text("Mahlzeiten"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: { withAnimation { self.showMenu.toggle() } },
                                label: { Image(systemName: "line.horizontal.3").padding() }
            ), trailing: EditButton())
            //            .resignKeyboardOnDragGesture()
        }
        
        ////            .resignKeyboardOnDragGesture()
        //        }
    }
}

//



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}


//func deleteFruit(offsets: IndexSet) {
//    fruits.remove(atOffsets: offsets)
//}
