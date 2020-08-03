//
//  DataFetcher.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation


class DataFetcher {
    
    let apiURL = "https://tor.publicbikesystem.net/ube/gbfs/v1/en/"
    
    
    func getLocations(completionHandler: @escaping (_ locations: [String: BikeStation]?, _ error: String?) -> Void) {
        let url = URL(string: "\(self.apiURL)/station_information")!
        
        // The bike station availability levels are fetched from a different source than the name
        // So 2 calls are needed here.
        self.populateBikes { (bikeStations, error) in
            if error == nil {
                AF.request(url).responseJSON { (response) in
                    if let data = response.data {
                        let jsonDict = try! JSONSerialization.jsonObject(with: data) as! NSDictionary
                        if let stationData = jsonDict["data"] as? NSDictionary {
                            // We have the station data
                            let stations = stationData["stations"] as! [[String: Any]]
                            
                            var savedStations: [String: BikeStation] = [:]
                            for station in stations {
                                let name = station["name"] as! String
                                let id = station["station_id"] as! String
                                let lat = station["lat"] as! Double
                                let lon = station["lon"] as! Double
                                
                                let bikeAvailability = bikeStations![id]
                                let mech = bikeAvailability!.0
                                let ebike = bikeAvailability!.1
                                let empty = bikeAvailability!.2
                                
                                savedStations[id] = BikeStation(name: name, stationID: id, coordinate:  CLLocationCoordinate2D(latitude: lat, longitude: lon), availableBikes: mech, availableEbike: ebike, availableDock: empty)
                                
                            }
                            completionHandler(savedStations, nil)
                        } else {
                            completionHandler(nil, "Error getting the station data")
                        }
                        
                    } else {
                        completionHandler(nil, "Error connecting to the server")
                    }
                }
            }
        }
        
        
        
    }
    
    /**
            Returns the station id, then a tuple of (Mechanical bike, E-bike, and empty docks)
     */
    func populateBikes(completion: @escaping (_ stations: [String: (Int, Int, Int)]?, _ error: String?) -> Void) {
        let url = URL(string: "\(self.apiURL)/station_status")!
        
        AF.request(url).responseJSON { (response) in
            if let data = response.data  {
                let jsonDict = try! JSONSerialization.jsonObject(with: data) as! NSDictionary
                if let stationData = jsonDict["data"] as? NSDictionary {
                    let stations = stationData["stations"] as! [[String: Any]]
                    var responseStations: [String: (Int, Int, Int)] = [:]
                    for station in stations {
                        let id = station["station_id"] as! String
                        let empty = station["num_docks_available"] as! Int
                        let bikeTypes = station["num_bikes_available_types"] as! [String: Any]
                        
                        let mechBikesAvailable = bikeTypes["mechanical"] as! Int
                        let ebikeAvailable = bikeTypes["ebike"] as! Int
                        
                        responseStations[id] = (mechBikesAvailable, ebikeAvailable, empty)
                        
                    }
                    completion(responseStations, nil)
                    
                }
                
            } else {
                completion(nil, "Error connecting to the server")
            }
        }
    }
}
