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
    let code: String
    let status: Int
    let statusVerbose: String
    let product: OffProduct?
    
    enum CodingKeys: String, CodingKey {
        case code
        case status
        case statusVerbose = "status_verbose"
        case product
    }

}

extension OffResponse: CustomStringConvertible {
    var description: String {
        var aString = ""
        aString.append(String("code:    \(code) \n"))
        aString.append(String("status:  \(status) (\(statusVerbose))\n"))
        if let product = product {
            aString.append(String("Product:\n \(product.description)"))
        }

        return aString
    }
}
