//
//  OffProduct.swift
//  Meals3
//
//  Created by Uwe Petersen on 03.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import Foundation

/// Holds the relevant product data from [Open Food Facts](https://wiki.openfoodfacts.org) ([API documentation](https://wiki.openfoodfacts.org/API)). like nutrient information and name of the product (food).
///
/// Some data (like the nutrition information) resides in sub structures within the json data. The relevant data of these sub structures is pulled out and moved to the top level (i.e. flattened) during the decoding process.
struct OffProduct: Decodable { // TODO: make Identifiable via variable "code" instead of hashable

    /// EAN code
    let code: String?
    let statusVerbose: String?
    let status: Int?
    let name: String?
    
    // Nutrition information from substructure nutriments being flattened
    var totalEnergyCals: Float?
    var totalCarbs: Float?
    var totalProtein: Float?
    var totalFat: Float?
    
    enum CodingKeys: String, CodingKey {
        case code
        case statusVerbose = "status_verbose"
        case status
        case name = "product_name"
        case nutriments
        // keys for data from substructure nutriments
        enum nutrimentsKeys: String, CodingKey {
            case totalEnergyCals = "energy-kcal_100g"
            case totalCarbs = "carbohydrates_100g"
            case totalProtein = "proteins_100g"
            case totalFat = "fat_100g"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        code           = try? container.decode(String.self, forKey: .code)
        status         = try? container.decode(Int.self, forKey: .status)
        statusVerbose  = try? container.decode(String.self, forKey: .statusVerbose)
        name           = try container.decode(String.self, forKey: .name)
        
        /// Container for the substructre `nutriments`
        if let nutrimentsContainer = try? container.nestedContainer(keyedBy: CodingKeys.nutrimentsKeys.self, forKey: .nutriments) {
            totalEnergyCals   = try nutrimentsContainer.decode(Float.self, forKey: .totalEnergyCals)
            totalCarbs   = try nutrimentsContainer.decode(Float.self, forKey: .totalCarbs)
            totalProtein   = try nutrimentsContainer.decode(Float.self, forKey: .totalProtein)
            totalFat   = try nutrimentsContainer.decode(Float.self, forKey: .totalFat)
        }
    }
}
extension OffProduct: CustomStringConvertible {
    public var description: String {
        var aString = ""
        aString.append("EAN code: \(code ?? "")\n")
        aString.append("Status: \(status ?? -1), '\(statusVerbose ?? "-")'\n")
        aString.append("Name: \(name ?? "-")\n")
        aString.append("totalEnergyCals: \(totalEnergyCals ?? -1)\n")
        aString.append("totalCarbs:      \(totalCarbs ?? -1)\n")
        aString.append("totalProtein:    \(totalProtein ?? -1)\n")
        aString.append("totalFat:        \(totalFat ?? -1)\n")
        return aString
    }
    
}
