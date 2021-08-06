//
//  BrandExtension.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData


extension Brand {
    
    class func createBrandWithName(_ name: String, inManagedObjectContext context: NSManagedObjectContext) -> Brand {
        let brand = Brand(context: context)
        brand.name = name
        return brand
    }

    
    class func fetchBrandsForName(_ name: String, managedObjectContext context: NSManagedObjectContext) -> [Brand]? {
        
        let request: NSFetchRequest<Brand> = Brand.fetchRequest()
        request.predicate = NSPredicate(format: "name = '\(name)'")
                
        do {
            let brands = try context.fetch(request)
            return brands
        } catch {
            print("Error fetching all brands: \(error)")
            return nil
        }
    }
}
