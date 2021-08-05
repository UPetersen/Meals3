//
//  OffManager.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import Foundation
import Combine

class OffManager: ObservableObject {
    @Published var state: OffManagerState = .idle
    @Published var scannedBarcode: String? = nil
    @Published var product: OffProduct? = nil
    @Published var offResponse: OffResponse? = nil

    let offApiUrl = URL(string: "https://world.openfoodfacts.org/api/v0/product")! // Get a product like this: https://world.openfoodfacts.org/api/v0/product/737628064502.json

        
    enum OffManagerState: Equatable {
        case isScanning
        case scanError(error: CodeScannerView.ScanError)
        case scanningCompleted
        case isFetching
        case fetchingCompleted
        case idle
        
        var description: String {
            switch self {
            case .isScanning:
                return "Scanning for Barcodes."
            case .scanningCompleted:
                return "Scanning completed."
            case .isFetching:
                return "Fetching information from Open Foods Facts."
            case .fetchingCompleted:
                return "Fetching completed."
            case .idle:
                return "Sanner im Ruhezustand."
            case .scanError(let error):
                switch error {
                case .badInput:
                    return "Fehler beim scannen: bad input"
                case .badOutput:
                    return "Fehler beim scannen: bad output"
                }
            }
        }
    }
    
    func scan() {
        state = .isScanning
        scannedBarcode = nil
        product = nil
    }
    
    func reset() {
        state = .idle
        scannedBarcode = nil
        product = nil
    }
    
    func finishedScanningWithResult(_ result: Result<String, CodeScannerView.ScanError>) {
        self.state = .scanningCompleted
        switch result {
        case .success(let code):
//            print("scanner found code \(code)")
            self.scannedBarcode = code
            self.fetch()
        case .failure(let error):
            self.failedScanning(error: error)
//            self.state = .scanError(error: error)
//            self.scannedBarcode = nil
//            print("scanner did not find any code")
        }
    }
    
    func fetch() {
        print("scanner found code \(scannedBarcode)")
        state = .isFetching
        fetchProduct(code: scannedBarcode!)
    }
    
    func failedScanning(error: CodeScannerView.ScanError) {
        state = .scanError(error: error)
        scannedBarcode = nil
        print("scanner did not find any code")
    }
    
    private func fetchProduct(code: String) {

        print("OffManager start of fetchProduct")

        let url = URL(string: offApiUrl.absoluteString + "/\(code)")!
        print(url.absoluteString)
        
        let request = NetworkRequest(url: url)

        request.execute { [weak self] (data) in
            if let data = data {
                print("received data")
                print(String(data: data, encoding: .utf8) ?? "Data could not be printed.")
                self?.decode(data)
                self?.state = .fetchingCompleted
                print(self?.offResponse.debugDescription ?? "No description for product")
            } else {
                print("Did not receive data")
            }
        }
 
        print("OffManager end of fetchProduct")

    }
    
    private func decode(_ data: Data) {

        print("OffManager start of decode")

        let decoder = JSONDecoder()
        offResponse = (try? decoder.decode(OffResponse.self, from: data))
        product = offResponse?.product
        
        print("OffManager end of decode")
        
    }

    
    func testJson() {
        let json =     """
        {
           "status_verbose": "product found",
           "status": 1,
           "code": "04963406",
           "product": {
             "code": "04963406",
             "product_name": "Coca-Cola",
             "nutriments": {
               "fiber_value": 0,
               "carbohydrates_100g": 11,
               "carbohydrates_value": 39,
               "energy_unit": "kcal",
               "sodium": 0.045,
               "energy_serving": 586,
               "proteins": 0,
               "fruits-vegetables-nuts-estimate-from-ingredients_100g": 0,
               "salt": 0.1125,
               "salt_100g": 0.0317,
               "sugars_value": 39,
               "saturated-fat_value": 0,
               "proteins_unit": "g",
               "energy": 586,
               "nova-group_100g": 4,
               "salt_serving": 0.1125,
               "nutrition-score-fr_100g": 14,
               "nutrition-score-fr": 14,
               "fat_value": 0,
               "carbohydrates_unit": "g",
               "nova-group_serving": 4,
               "energy-kcal_value": 140,
               "energy-kcal_100g": 39.4,
               "fiber": 0,
               "sugars": 39,
               "fat_serving": 0,
               "proteins_value": 0,
               "nova-group": 4,
               "energy-kcal_serving": 140,
               "saturated-fat_unit": "g",
               "fat": 0,
               "energy-kcal_unit": "kcal",
               "proteins_100g": 0,
               "fiber_serving": 0,
               "energy_100g": 165,
               "energy-kcal": 140,
               "salt_value": 112.5,
               "sugars_unit": "g",
               "fiber_100g": 0,
               "proteins_serving": 0,
               "sugars_serving": 39,
               "sodium_unit": "mg",
               "salt_unit": "mg",
               "fat_unit": "g",
               "carbohydrates": 39,
               "sodium_100g": 0.0127,
               "saturated-fat": 0,
               "energy_value": 140,
               "fiber_unit": "g",
               "sodium_value": 45,
               "fat_100g": 0,
               "carbohydrates_serving": 39,
               "sodium_serving": 0.045,
               "sugars_100g": 11,
               "saturated-fat_serving": 0,
               "saturated-fat_100g": 0
             }
           }
         }
        """.data(using: .utf8)!

    }






    
}