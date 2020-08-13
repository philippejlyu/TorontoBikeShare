//
//  NearbyInterfaceController.swift
//  TorontoBikeShare WatchKit Extension
//
//  Created by Philippe Yu on 2020-08-10.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import WatchKit

class NearbyInterfaceController: WKInterfaceController, SortedLocationsDelegate {
    
    @IBOutlet weak var favoritesTable: WKInterfaceTable!
    
    var stations: [BikeStation] = []
    var nearby: FindNearby!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        // TODO: Fetch the data from the server
        
        // Debug purposes only
        let debugStation = BikeStation(name: "Spadina Ave / Willcocks St", stationID: "7170", lat: 43.661672, lon: -79.401387, availableBikes: 1, availableEbike: 0, availableDock: 14, distance: 0)
        self.stations.append(debugStation)
        
        DataFetcher().getLocations { (locations, error) in
            print("Getting locations")
            if error == nil && locations != nil {
                print("Got the locations")
                guard let stationLocations = locations else { return }
                self.stations = FavoritePersistence().processFavoriteLocations(favoriteLocations: stationLocations)
                // Now we want to sort everything and get the result in the delegate callback
                self.nearby = FindNearby(locations: self.stations)
                self.nearby.delegate = self
                self.nearby.requestCurrentLocation()
            }
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Table related
    
    func setupTable() {
               
        // We do this instead of setRowCount because apparently that doesn't work
        // We also want to ensure that the first row is always a row that says nearby
        
        for index in 0..<self.favoritesTable.numberOfRows {
            guard let controller = favoritesTable.rowController(at: index) as? FavoritesRowController else { continue }
            controller.initializeInformation(information: self.stations[index])
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let station = self.stations[rowIndex]
        pushController(withName: "StationInferface", context: station)

    }
    
    // MARK: - SortedLocationDelegate
    func didFinishSorting(locations: [BikeStation]) {
        print("Did finish sorting locations")
        self.stations = locations
        self.favoritesTable.setNumberOfRows(locations.count, withRowType: "favoriteRow")
        self.setupTable()
    }
}
