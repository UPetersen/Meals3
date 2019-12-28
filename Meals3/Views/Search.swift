//
//  Search.swift
//  Meals3
//
//  Created by Uwe Petersen on 23.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//
import Combine

class Search: ObservableObject {
    @Published var text: String = "Eier" {
        didSet {
            fetchOffset = 0
            print("did set fetchoffset to zero")
        } // Enforces reload
    }
    @Published var filter: SearchFilter = .Contains
    @Published var sortRule: FoodListSortRule = .NameAscending
    @Published var foodListType: FoodListType = .All
    @Published var fetchLimit: Int = 50
    @Published var fetchOffset: Int = 0
}
