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
    /// Distance is only used on the watch app when we are trying to sort nearby places, otherwise, it is irrelevant and will be set to 0
    var distance: Double
    
    func copy() -> BikeStation {
        return BikeStation(name: name, stationID: stationID, lat: lat, lon: lon, availableBikes: availableBikes, availableEbike: availableEbike, availableDock: availableDock, distance: distance)
    }
    
}
