//
//  Restaurant.swift
//  FoodTracker
//
//  Created by Celia on 19/05/2016.
//  Copyright © 2016 Fanigan. All rights reserved.
//

import Foundation
import MapKit

class Restaurant: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    var street: String?
    var city: String?
    var zip: String?
    var country: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}