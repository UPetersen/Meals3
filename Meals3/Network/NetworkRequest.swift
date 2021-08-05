//
//  NetworkRequest.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import Foundation

class NetworkRequest {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func execute(withCompletion completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, _, _) -> Void in
            DispatchQueue.main.async {
                completion(data)
            }
        })
        task.resume()
    }
}
