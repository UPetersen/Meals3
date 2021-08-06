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
    let name: String?
    
    // Nutrition information from substructure nutriments being flattened
    var energyCals: Float?
    var carbs: Float?
    var protein: Float?
    var fat: Float?
    var saturatedFat: Float?
    var sugar: Float?
    var fiber: Float?
    var salt: Float?
    
    var brand: String?
    var created: Date?
    var creator: String?
    var lastModified: Date?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name = "product_name"
        case brand = "brands"
        case created = "created_t"
        case creator
        case lastModified = "last_modified_t"
        
        case nutriments
        // keys for data from substructure nutriments
        enum nutrimentsKeys: String, CodingKey {
            case energyCals = "energy-kcal_100g"
            case carbs = "carbohydrates_100g"
            case protein = "proteins_100g"
            case fat = "fat_100g"
            case saturatedFat = "saturated-fat"
            case sugar = "sugars_100g"
            case fiber = "fiber_100g"
            case salt = "salt_100g"
        }
    }
    
    init(from decoder: Decoder) throws {

        let container  = try decoder.container(keyedBy: CodingKeys.self)
        code           = try? container.decode(String.self, forKey: .code)
        name           = try? container.decode(String.self, forKey: .name)
        brand          = try? container.decode(String.self, forKey: .brand)
        created = try? container.decode(Date.self, forKey: .created)
        creator = try? container.decode(String.self, forKey: .creator)
        lastModified = try? container.decode(Date.self, forKey: .lastModified)

        /// Container for the substructre `nutriments`
        if let nutrimentsContainer = try? container.nestedContainer(keyedBy: CodingKeys.nutrimentsKeys.self, forKey: .nutriments) {
            energyCals   = try? nutrimentsContainer.decode(Float.self, forKey: .energyCals)
            carbs        = try? nutrimentsContainer.decode(Float.self, forKey: .carbs)
            protein      = try? nutrimentsContainer.decode(Float.self, forKey: .protein)
            fat          = try? nutrimentsContainer.decode(Float.self, forKey: .fat)
            saturatedFat = try? nutrimentsContainer.decode(Float.self, forKey: .saturatedFat)
            sugar        = try? nutrimentsContainer.decode(Float.self, forKey: .sugar)
            fiber        = try? nutrimentsContainer.decode(Float.self, forKey: .fiber)
            salt         = try? nutrimentsContainer.decode(Float.self, forKey: .salt)
        }
    }
}
extension OffProduct: CustomStringConvertible {
    public var description: String {
        var aString = ""
        aString.append("code:         \(String(describing: code))\n")
        aString.append("Name:         \(String(describing: name))\n")
        aString.append("energyCals:   \(String(describing: energyCals))\n")
        aString.append("varbs:        \(String(describing: carbs))\n")
        aString.append("protein:      \(String(describing: protein))\n")
        aString.append("tfat:         \(String(describing: fat))\n")
        aString.append("saturatedFat: \(String(describing: saturatedFat))\n")
        aString.append("sugar:        \(String(describing: sugar))\n")
        aString.append("fiber:        \(String(describing: fiber))\n")
        aString.append("salt:         \(String(describing: salt))\n")
        aString.append("brand:        \(String(describing: brand))\n")
        aString.append("created:      \(String(describing: created))\n")
        aString.append("creator:      \(String(describing: creator))\n")
        aString.append("lastModified: \(String(describing: lastModified))\n")
        return aString
    }
    
}
