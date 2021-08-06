//
//  NetworkRequest.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import Foundation

class NetworkRequest {
    let urlRequest: URLRequest
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    // URLResponse?, Error?
    func execute(withCompletion completion: @escaping (Data?) -> Void) {
        
//        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) -> Void in
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, _, _) -> Void in
            DispatchQueue.main.async {
                completion(data)
            }
        })
        task.resume()
    }
}
