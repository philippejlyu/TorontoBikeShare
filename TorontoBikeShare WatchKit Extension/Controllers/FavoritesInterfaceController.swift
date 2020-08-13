//
//  FavoritesInterfaceController.swift
//  TorontoBikeShare WatchKit Extension
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import WatchKit
import Foundation


class FavoritesInterfaceController: WKInterfaceController {

    @IBOutlet weak var favoritesTable: WKInterfaceTable!
    @IBOutlet weak var addOniPhoneLabel: WKInterfaceLabel!
    
    var favorites: [BikeStation] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        self.registerForDataNotifications()
        
        let persistence = FavoritePersistence()
        let favDict = persistence.retrieveFavorites()
        self.favorites = persistence.processFavoriteLocations(favoriteLocations: favDict)
        
        // Debug purposes only
        let debugStation = BikeStation(name: "Spadina Ave / Willcocks St", stationID: "7170", lat: 43.661672, lon: -79.401387, availableBikes: 1, availableEbike: 0, availableDock: 14, distance: 0)
        self.favorites.append(debugStation)
        setupTable()
        
    }
    
    deinit {
        self.deregisterForDataNotifications()
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
        if self.favorites.count > 0 {
            self.addOniPhoneLabel.setHidden(true)
        } else {
            self.addOniPhoneLabel.setHidden(false)
        }
        
        // We do this instead of setRowCount because apparently that doesn't work
        // We also want to ensure that the first row is always a row that says nearby
        var rowTypes = ["nearbyRow"]
        for i in 0..<self.favorites.count {
            rowTypes.append("favoriteRow")
        }
        self.favoritesTable.setRowTypes(rowTypes)
        for index in 1..<self.favoritesTable.numberOfRows {
            guard let controller = favoritesTable.rowController(at: index) as? FavoritesRowController else { continue }
            controller.initializeInformation(information: self.favorites[index - 1])
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        // We do -1 because of the nearby button thats there
        let station = self.favorites[rowIndex - 1]
        pushController(withName: "StationInferface", context: station)

    }
    
    // MARK: - Data related
    func registerForDataNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addFavorite(notification:)), name: Notification.Name("com.philippeyu.bike.stationAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeFavorite(notification:)), name: Notification.Name("com.philippeyu.bike.stationRemoved"), object: nil)
    }
    
    func deregisterForDataNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("com.philippeyu.bike.stationAdded"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("com.philippeyu.bike.stationRemoved"), object: nil)
        
    }
    
    @objc func addFavorite(notification: Notification) {
        print("Did receive add notification")
        guard let station = notification.object as? BikeStation else { return }
        self.favorites.append(station)
        self.setupTable()
    }
    
    @objc func removeFavorite(notification: Notification) {
        print("Did receive remove notification")
        guard let station = notification.object as? BikeStation else { return }
        for i in 0..<self.favorites.count {
            if self.favorites[i].stationID == station.stationID {
                self.favorites.remove(at: i)
                self.setupTable()
                break
            }
        }
    }

}
