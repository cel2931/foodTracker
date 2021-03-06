//
//  Meal.swift
//  FoodTracker
//
//  Created by Celia on 18/04/2016.
//  Copyright © 2016 Fanigan. All rights reserved.
//

import UIKit

class Meal: NSObject {

    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var address: String?
    var rating: Int

    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
        static let addressKey = "address"
    }
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int, address: String?) {
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.address = address
        super.init()
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        let address = aDecoder.decodeObjectForKey(PropertyKey.addressKey) as? String
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, address:address)
    }
}

// MARK: - NSCoding

extension Meal: NSCoding {

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
        aCoder.encodeObject(address, forKey: PropertyKey.addressKey)
    }
}

