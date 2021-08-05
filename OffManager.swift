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
    @Published var offManagerState: OffManagerState = .idle
    @Published var scannedBarcode: String? = nil
    @Published var product: OffProduct? = nil
    @Published var offResponse: OffResponse? = nil

//    var networkController = NetworkController()
    let offApiUrl = URL(string: "https://world.openfoodfacts.org/api/v0/product")!

        
    enum OffManagerState: String {
        case isScanning
        case scanningCompleted
        case isFetching
        case fetchingCompleted
        case idle
    }
    
    func scan() {
        offManagerState = .isScanning
        scannedBarcode = nil
        product = nil
    }
    
    func reset() {
        offManagerState = .idle
        scannedBarcode = nil
        product = nil
    }
    
    func fetch() {
        if let code = scannedBarcode {
            offManagerState = .isFetching
            fetchProduct(code: code)
        } else {
            offManagerState = .idle
        }
    }
    
    
    
    private func fetchProduct(code: String) {

        print("OffManager start of fetchProduct")

        let url = URL(string: offApiUrl.absoluteString + "/\(code)")!
        print(url.absoluteString)
//        let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/737628064502.json")!
//        let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/04963406.json")!
        
        let request = NetworkRequest(url: url)
        request.execute { [weak self] (data) in
            if let data = data {
                print("received data")
                print(String(data: data, encoding: .utf8) ?? "Data could not be printed.")
                self?.decode(data)
                self?.offManagerState = .fetchingCompleted
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


    
}
