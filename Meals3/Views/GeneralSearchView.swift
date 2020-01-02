//
//  GeneralSearchView.swift
//  Meals3
//
//  Created by Uwe Petersen on 22.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI


struct GeneralSearchView<T>: View where T: IngredientCollection  {
//struct GeneralSearchView: View  {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var ingredientCollection: T

    @EnvironmentObject var currentIngredientCollection: CurrentIngredientCollection // hier kommt das an!

    
    let oneMaxDigitsNumberFormatter: NumberFormatter =  {() -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        numberFormatter.zeroSymbol = "0"
        return numberFormatter
    }()

    @ObservedObject var search = Search()

    var body: some View {
        
         VStack{
            SearchBarView(searchText: $search.text)
                .resignKeyboardOnDragGesture()

            
            GeneralSearchResultsView(search: search, formatter: oneMaxDigitsNumberFormatter, ingredientCollection: self.ingredientCollection)
//            GeneralSearchResultsView(search: search, formatter: oneMaxDigitsNumberFormatter)

            // Bottom tool bar
//            GeneralSearchViewToolbar()
         }
//         .environmentObject(self.currentIngredientCollection)
//         .onAppear() {
//            print(self.oneMaxDigitsNumberFormatter.description)
//        }
    }
}

//struct GeneralSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        return NavigationView {
//            return GeneralSearchView()
////                .environmentObject(Search())
//                .environment(\.managedObjectContext, viewContext)
//                .navigationBarTitle("General search")
//        }
//    }
//}
