//
//  OffResponse.swift
//  Meals3
//
//  Created by Uwe Petersen on 03.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import Foundation


/// Holds the response of the top level structure of a json response from [Open Food Facts API](https://wiki.openfoodfacts.org/API) ([API documentation](https://wiki.openfoodfacts.org/API)).
///
/// Only relevant information is decoded.
struct OffResponse: Decodable {
    let product: OffProduct
    let code: String
}

extension OffResponse: CustomDebugStringConvertible {
    var debugDescription: String {
        return String("code: \(code) \n\(product.description)")
    }
}
