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

            Button(action: {
                self.showingSelection.toggle()
            }) {
                Text(search.foodListType.rawValue)
            }
            .actionSheet(isPresented: $showingSelection) { selectionActionSheet() }
            
            Spacer()
            
            Button(action: {
                self.toggleSearchFilter()
            }) {
                Text(search.filter == SearchFilter.Contains ? "'   ...  '" : "'...     '").fontWeight(.bold)
            }
            
            Spacer()
            
            Button(action: {
                self.showingSortRules.toggle()
            }) {
                Text(search.sortRule.rawValue)
            }
            .actionSheet(isPresented: $showingSortRules) { sortRuleActionSheet() }
        }
        .padding()
    }
    
    func toggleSearchFilter() {
        self.search.filter = self.search.filter == .Contains ? .BeginsWith : .Contains
    }
    
    func sortRuleActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Welche Lebensmitteln sollen genutzt werden?"), message: nil, buttons: [
            .default(Text(FoodListSortRule.NameAscending.rawValue)){ self.search.sortRule = .NameAscending },
            .default(Text(FoodListSortRule.TotalEnergyCalsDescending.rawValue)){ self.search.sortRule = .TotalEnergyCalsDescending },
            .default(Text(FoodListSortRule.TotalCarbDescending.rawValue)){ self.search.sortRule = .TotalCarbDescending },
            .default(Text(FoodListSortRule.TotalProteinDescending.rawValue)){ self.search.sortRule = .TotalProteinDescending },
            .default(Text(FoodListSortRule.TotalFatDescending.rawValue)){ self.search.sortRule = .TotalFatDescending },
            .default(Text(FoodListSortRule.FattyAcidCholesterolDescending.rawValue)){ self.search.sortRule = .FattyAcidCholesterolDescending },
            .default(Text(FoodListSortRule.GroupThenSubGroupThenNameAscending.rawValue)){ self.search.sortRule = .GroupThenSubGroupThenNameAscending }
            ]
        )
    }
    func selectionActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Welche Lebensmitteln sollen genutzt werden?"), message: nil, buttons: [
            .default(Text(FoodListType.Favorites.rawValue)){ self.search.foodListType = .Favorites },
            .default(Text(FoodListType.Recipes.rawValue)){ self.search.foodListType = .Recipes },
            .default(Text(FoodListType.LastWeek.rawValue)){ self.search.foodListType = .LastWeek },
            .default(Text(FoodListType.OwnEntries.rawValue)){ self.search.foodListType = .OwnEntries },
            .default(Text(FoodListType.MealIngredients.rawValue)){ self.search.foodListType = .MealIngredients },
            .default(Text(FoodListType.BLS.rawValue)){ self.search.foodListType = .BLS },
            .default(Text(FoodListType.All.rawValue)){ self.search.foodListType = .All }
            ]
        )
    }
}

struct GeneralSearchToolbar_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSearchToolbar(search: Search())
    }
}
