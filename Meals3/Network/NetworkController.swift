////
////  NetworkController.swift
////  Meals3
////
////  Created by Uwe Petersen on 04.08.21.
////  Copyright © 2021 Uwe Petersen. All rights reserved.
////
//
//import Foundation
//
//
//class NetworkController: ObservableObject {
//    @Published var offResponse: OffResponse? = nil
//    
////    func fetchProduct(code: String) {
//////        var code: String
////        let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(code)")!
////        print(url.absoluteString)
//////        let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/737628064502.json")!
//////        let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/04963406.json")!
////        let request = NetworkRequest(url: url)
////        request.execute { [weak self] (data) in
////            if let data = data {
////                print("received data")
////                print(String(data: data, encoding: .utf8))
////                self?.decode(data)
////                print(self?.offResponse.debugDescription)
////            } else {
////                print("did not receive data")
////            }
////        }
////    }
//}
//
//private extension NetworkController {
//    func decode(_ data: Data) {
//        let decoder = JSONDecoder()
//        offResponse = (try? decoder.decode(OffResponse.self, from: data))
//        print(String(data: data, encoding: .utf8) ?? "doch nicht")
//        print("From the network:")
//        print("Code: \(offResponse?.code)")
//        print("Code: \(offResponse?.product.code ?? "no code")")
//        print("Name: \(offResponse?.product.name ?? "no code")")
//        print("totalEnergyCals: \(offResponse?.product.totalEnergyCals ?? -1)")
//        print("totalCarbs:      \(offResponse?.product.totalCarbs ?? -1)")
//        print("totalProtein:    \(offResponse?.product.totalProtein ?? -1)")
//        print("totalFat:        \(offResponse?.product.totalFat ?? -1)")
//
//    }
//}
