//
//  FavoritesRowController.swift
//  TorontoBikeShare WatchKit Extension
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import WatchKit

class FavoritesRowController: NSObject {

    @IBOutlet var stationNameLabel: WKInterfaceLabel!
    
    var stationInformation: NSDictionary = [:]
    
    func initializeInformation(information: NSDictionary) {
        self.stationInformation = information
        let name = self.stationInformation["station name"] as! String
        self.stationNameLabel.setText(name)
    }
}
