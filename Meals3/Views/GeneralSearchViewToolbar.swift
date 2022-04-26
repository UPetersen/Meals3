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
    @ObservedObject var searchViewModel: SearchViewModel
    
    @State private var showingSelection = false
    @State private var showingSortRules = false

    var body: some View {
        HStack {
            Button(action: { self.showingSelection.toggle() }) {
                Text(searchViewModel.selection.rawValue)
                
            }
            .actionSheet(isPresented: $showingSelection) { selectionActionSheet() }

            Spacer()

            Button(action: { toggleSearchFilter() }) {
                Text(searchViewModel.filter == SearchFilter.contains ? "'   ...   '" : "'...      '").fontWeight(.bold)
            }

            Spacer()

            Button(action: { showingSortRules.toggle() }) {
                Text(searchViewModel.sortRule.rawValue)
            }
            .actionSheet(isPresented: $showingSortRules) { sortRuleActionSheet() }
        }
        .padding()
    }
    
    func toggleSearchFilter() {
        searchViewModel.filter = searchViewModel.filter == .contains ? .beginsWith : .contains
    }
    
    func sortRuleActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Wonach soll sortiert werden?"), message: nil, buttons: [
            .default(Text(FoodListSortRule.nameAscending.rawValue)                    ){ searchViewModel.sortRule = .nameAscending },
            .default(Text(FoodListSortRule.totalEnergyCalsDescending.rawValue)         ){ searchViewModel.sortRule = .totalEnergyCalsDescending },
            .default(Text(FoodListSortRule.totalCarbDescending.rawValue)               ){ searchViewModel.sortRule = .totalCarbDescending },
            .default(Text(FoodListSortRule.totalProteinDescending.rawValue)            ){ searchViewModel.sortRule = .totalProteinDescending },
            .default(Text(FoodListSortRule.totalFatDescending.rawValue)                ){ searchViewModel.sortRule = .totalFatDescending },
            .default(Text(FoodListSortRule.fattyAcidCholesterolDescending.rawValue)    ){ searchViewModel.sortRule = .fattyAcidCholesterolDescending },
            .default(Text(FoodListSortRule.groupThenSubGroupThenNameAscending.rawValue)){ searchViewModel.sortRule = .groupThenSubGroupThenNameAscending },
            .cancel(Text("Zurück"))
            ]
        )
    }
    
    func selectionActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Welche Lebensmittel sollen genutzt werden?"), message: nil, buttons: [
            .default(Text(FoodListSelection.favorites.rawValue)      ){ searchViewModel.selection = .favorites },
            .default(Text(FoodListSelection.recipes.rawValue)        ){ searchViewModel.selection = .recipes },
            .default(Text(FoodListSelection.lastWeek.rawValue)       ){ searchViewModel.selection = .lastWeek },
            .default(Text(FoodListSelection.ownEntries.rawValue)     ){ searchViewModel.selection = .ownEntries },
            .default(Text(FoodListSelection.mealIngredients.rawValue)){ searchViewModel.selection = .mealIngredients },
            .default(Text(FoodListSelection.bls.rawValue)            ){ searchViewModel.selection = .bls },
            .default(Text(FoodListSelection.openFoodFacts.rawValue)  ){ searchViewModel.selection = .openFoodFacts },
            .default(Text(FoodListSelection.all.rawValue)            ){ searchViewModel.selection = .all },
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
                GeneralSearchViewToolbar(searchViewModel: SearchViewModel())
            }
        }
        .navigationBarTitle("Lebensmittel")
    }
}
