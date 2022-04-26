//
//  GeneralSearchToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct GeneralSearchViewToolbar: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var search: SearchViewModel
    
    @State private var showingSelection = false
    @State private var showingSortRules = false

    var body: some View {
        HStack {
            Button(action: { self.showingSelection.toggle() }) {
                Text(search.selection.rawValue)
                
            }
            .actionSheet(isPresented: $showingSelection) { selectionActionSheet() }

            Spacer()

            Button(action: { toggleSearchFilter() }) {
                Text(search.filter == SearchFilter.contains ? "'   ...   '" : "'...      '").fontWeight(.bold)
            }

            Spacer()

            Button(action: { showingSortRules.toggle() }) {
                Text(search.sortRule.rawValue)
            }
            .actionSheet(isPresented: $showingSortRules) { sortRuleActionSheet() }
        }
        .padding()
    }
    
    func toggleSearchFilter() {
        search.filter = search.filter == .contains ? .beginsWith : .contains
    }
    
    func sortRuleActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Wonach soll sortiert werden?"), message: nil, buttons: [
            .default(Text(FoodListSortRule.nameAscending.rawValue)                    ){ search.sortRule = .nameAscending },
            .default(Text(FoodListSortRule.totalEnergyCalsDescending.rawValue)         ){ search.sortRule = .totalEnergyCalsDescending },
            .default(Text(FoodListSortRule.totalCarbDescending.rawValue)               ){ search.sortRule = .totalCarbDescending },
            .default(Text(FoodListSortRule.totalProteinDescending.rawValue)            ){ search.sortRule = .totalProteinDescending },
            .default(Text(FoodListSortRule.totalFatDescending.rawValue)                ){ search.sortRule = .totalFatDescending },
            .default(Text(FoodListSortRule.fattyAcidCholesterolDescending.rawValue)    ){ search.sortRule = .fattyAcidCholesterolDescending },
            .default(Text(FoodListSortRule.groupThenSubGroupThenNameAscending.rawValue)){ search.sortRule = .groupThenSubGroupThenNameAscending },
            .cancel(Text("Zurück"))
            ]
        )
    }
    
    func selectionActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Welche Lebensmittel sollen genutzt werden?"), message: nil, buttons: [
            .default(Text(FoodListSelection.favorites.rawValue)      ){ search.selection = .favorites },
            .default(Text(FoodListSelection.recipes.rawValue)        ){ search.selection = .recipes },
            .default(Text(FoodListSelection.lastWeek.rawValue)       ){ search.selection = .lastWeek },
            .default(Text(FoodListSelection.ownEntries.rawValue)     ){ search.selection = .ownEntries },
            .default(Text(FoodListSelection.mealIngredients.rawValue)){ search.selection = .mealIngredients },
            .default(Text(FoodListSelection.bls.rawValue)            ){ search.selection = .bls },
            .default(Text(FoodListSelection.openFoodFacts.rawValue)  ){ search.selection = .openFoodFacts },
            .default(Text(FoodListSelection.all.rawValue)            ){ search.selection = .all },
            .cancel(Text("Zurück"))
            ]
        )
    }
}

struct GeneralSearchToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Spacer()
                GeneralSearchViewToolbar(search: SearchViewModel())
            }
        }
        .navigationBarTitle("Lebensmittel")
    }
}
