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
    
    var stationInformation: BikeStation?
    
    func initializeInformation(information: BikeStation) {
        self.stationInformation = information
        self.stationNameLabel.setText(information.name)
    }
}
