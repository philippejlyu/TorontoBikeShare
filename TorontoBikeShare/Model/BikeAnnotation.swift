//
//  BikeAnnotation.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import Foundation
import MapKit

class BikeAnnotation: NSObject, MKAnnotation {
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var subtitle: String?
    
    var isFavorite: Bool = false
    
    var station: BikeStation?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
