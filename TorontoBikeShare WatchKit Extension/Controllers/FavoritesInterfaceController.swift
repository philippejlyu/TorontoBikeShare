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
//        let debugStation = BikeStation(name: "Spadina Ave / Willcocks St", stationID: "7170", lat: 43.661672, lon: -79.401387, availableBikes: 1, availableEbike: 0, availableDock: 14)
//        self.favorites.append(debugStation)
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
        self.favoritesTable.setNumberOfRows(self.favorites.count, withRowType: "favoriteRow")
        for index in 0..<self.favoritesTable.numberOfRows {
            guard let controller = favoritesTable.rowController(at: index) as? FavoritesRowController else { continue }
            controller.initializeInformation(information: self.favorites[index])
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let station = self.favorites[rowIndex]
        pushController(withName: "StationInferface", context: station)

    }
    
    // MARK: - Data related
    func registerForDataNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addFavorite(notification:)), name: Notification.Name("stationAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeFavorite(notification:)), name: Notification.Name("stationRemoved"), object: nil)
    }
    
    func deregisterForDataNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("stationAdded"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("stationRemoved"), object: nil)
        
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
