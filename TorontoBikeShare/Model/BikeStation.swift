//
//  BikeStation.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import Foundation
import CoreLocation

struct BikeStation: Codable {
    
    var name: String
    var stationID: String
    var lat: Double
    var lon: Double
    var availableBikes: Int
    var availableEbike: Int
    var availableDock: Int
    
}
