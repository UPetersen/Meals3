//
//  GeneralSearchToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.01.20.
//  Copyright © 2020 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct GeneralSearchToolbar: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var search: Search
    
    @State private var showingSelection = false
    @State private var showingSortRules = false

    var body: some View {
        HStack {
            Button(action: { self.showingSelection.toggle() }) {
                Text(search.selection.rawValue)
                
            }
            .actionSheet(isPresented: $showingSelection) { selectionActionSheet() }

            Spacer()

            Button(action: { self.toggleSearchFilter() }) {
                Text(search.filter == SearchFilter.Contains ? "'   ...   '" : "'...      '").fontWeight(.bold)
            }

            Spacer()

            Button(action: { self.showingSortRules.toggle() }) {
                Text(search.sortRule.rawValue)
            }
            .actionSheet(isPresented: $showingSortRules) { sortRuleActionSheet() }
        }
        .padding()
    }
    
    func toggleSearchFilter() {
        search.filter = search.filter == .Contains ? .BeginsWith : .Contains
    }
    
    func sortRuleActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Wonach soll sortiert werden?"), message: nil, buttons: [
            .default(Text(FoodListSortRule.nameAscending.rawValue)){ self.search.sortRule = .nameAscending },
            .default(Text(FoodListSortRule.totalEnergyCalsDescending.rawValue)){ self.search.sortRule = .totalEnergyCalsDescending },
            .default(Text(FoodListSortRule.totalCarbDescending.rawValue)){ self.search.sortRule = .totalCarbDescending },
            .default(Text(FoodListSortRule.totalProteinDescending.rawValue)){ self.search.sortRule = .totalProteinDescending },
            .default(Text(FoodListSortRule.totalFatDescending.rawValue)){ self.search.sortRule = .totalFatDescending },
            .default(Text(FoodListSortRule.fattyAcidCholesterolDescending.rawValue)){ self.search.sortRule = .fattyAcidCholesterolDescending },
            .default(Text(FoodListSortRule.groupThenSubGroupThenNameAscending.rawValue)){ self.search.sortRule = .groupThenSubGroupThenNameAscending },
            .cancel(Text("Zurück"))
            ]
        )
    }
    
    func selectionActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Welche Lebensmittel sollen genutzt werden?"), message: nil, buttons: [
            .default(Text(FoodListSelection.favorites.rawValue)){ self.search.selection = .favorites },
            .default(Text(FoodListSelection.recipes.rawValue)){ self.search.selection = .recipes },
            .default(Text(FoodListSelection.lastWeek.rawValue)){ self.search.selection = .lastWeek },
            .default(Text(FoodListSelection.ownEntries.rawValue)){ self.search.selection = .ownEntries },
            .default(Text(FoodListSelection.mealIngredients.rawValue)){ self.search.selection = .mealIngredients },
            .default(Text(FoodListSelection.bls.rawValue)){ self.search.selection = .bls },
            .default(Text(FoodListSelection.openFoodFacts.rawValue)){ self.search.selection = .openFoodFacts },
            .default(Text(FoodListSelection.all.rawValue)){ self.search.selection = .all },
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
                GeneralSearchToolbar(search: Search())
            }
        }
        .navigationBarTitle("Lebensmittel")
    }
}
