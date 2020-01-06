//
//  Search.swift
//  Meals3
//
//  Created by Uwe Petersen on 23.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//
import Combine

class Search: ObservableObject {
    @Published var text: String = "" {
        didSet {
            fetchOffset = 0
//            print("did set fetchoffset to zero")
        } // Enforces refetch of data if search string is modified
    }
    @Published var filter: SearchFilter = .Contains
    @Published var sortRule: FoodListSortRule = .NameAscending
    @Published var selection: FoodListSelection = .All
//    @Published var selection: FoodListSelection = .LastWeek
    @Published var fetchLimit: Int = 50
    @Published var fetchOffset: Int = 0
}
