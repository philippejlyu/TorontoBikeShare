//
//  BikeStation.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import Foundation
import CoreLocation

struct BikeStation {
    
    var name: String
    var stationID: String
    var coordinate: CLLocationCoordinate2D
    var availableBikes: Int
    var availableEbike: Int
    var availableDock: Int
    
}
