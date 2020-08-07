//
//  FavoritePersistence.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-06.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import Foundation
import WatchConnectivity

class FavoritePersistence {
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Favourites.plist")
    }
        
    /// Retreives the favorites from the plist file on the iPhone and returns it in a dictionary [stationID: BikeStation]
    func retrieveFavorites() -> [String: BikeStation] {
        var favourites: [String: BikeStation] = [:]
        guard let plistData = self.readFromPlist() else { return favourites }
        for location in plistData {
            let station = BikeStation(name: location["name"] as! String, stationID: location["stationID"] as! String, lat: location["lat"] as! Double, lon: location["lon"] as! Double, availableBikes: location["availableBikes"] as! Int, availableEbike: location["availableEbike"] as! Int, availableDock: location["availableDock"] as! Int)
            favourites[location["stationID"] as! String] = station
        }
        return favourites
    }
    
    func readFromPlist() -> [NSDictionary]? {
        if let favorites = NSArray(contentsOf: self.dataFilePath()) as? [NSDictionary] {
            return favorites
        }
        return nil
    }
    
    /// Saves `data` to the favorite plist file on the iPhone
    fileprivate func saveArrayToPlist(data: [BikeStation]) {
        // This saves to a plist file in the documents directory of the iphone
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(data)
            try data.write(to: self.dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding or writing: \(error.localizedDescription)")
        }
    }
    
    /// Save the dictionary `locations` to a file in the app documents
    func saveAllToPlist(locations: [String: BikeStation]) {
        let processedLocations = self.processFavoriteLocations(favoriteLocations: locations)
        self.saveArrayToPlist(data: processedLocations)
    }
    
    /// Turns a dictionary of favorite bike stations to just an array of bike stations
    func processFavoriteLocations(favoriteLocations: [String: BikeStation]) -> [BikeStation] {
        var stations: [BikeStation] = []
        for key in favoriteLocations.keys {
            stations.append(favoriteLocations[key]!)
        }
        return stations
    }
    
    /// Sends `bikeStation` to the watch to be added or removed
    func sendDataToWatch(bikeStation: BikeStation, add: Bool) {
        let data: [String: Any] = ["name": bikeStation.name, "stationID": bikeStation.stationID, "lat": bikeStation.lat, "lon": bikeStation.lon, "availableBike": bikeStation.availableBikes, "availableEbike": bikeStation.availableEbike, "availableDocks": bikeStation.availableDock, "add": add]
        
        WCSession.default.transferUserInfo(data)
    }
    
    /// Takes a dictionary and returns a BikeStation from the data it is given
    func dictToBikeStation(dict: [String: Any]) -> BikeStation? {
        guard let name = dict["name"] as? String else { return nil }
        guard let stationID = dict["stationID"] as? String else { return nil }
        guard let lat = dict["lat"] as? Double else { return nil }
        guard let lon = dict["lon"] as? Double else { return nil }
        guard let availableBikes = dict["availableBike"] as? Int else { return nil }
        guard let availableEbike = dict["availableEbike"] as? Int else { return nil }
        guard let availableDock = dict["availableDocks"] as? Int else { return nil }
        return BikeStation(name: name, stationID: stationID, lat: lat, lon: lon, availableBikes: availableBikes, availableEbike: availableEbike, availableDock: availableDock)
    }
}
