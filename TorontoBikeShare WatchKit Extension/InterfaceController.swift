//
//  InterfaceController.swift
//  TorontoBikeShare WatchKit Extension
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    // MARK: - Properties
    var stationID = ""
    var stationName = ""
    var availableBikes = 0
    var availableDocks = 0
    var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()

    // MARK: - Outlets
    @IBOutlet weak var stationNameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var availableBikesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var availableDocksLabel: WKInterfaceLabel!
    
    @IBOutlet weak var map: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let fetcher = DataFetcher()
        fetcher.populateBikes { (bikes, error) in
            if error == nil {
                if let stationInfo = bikes?[self.stationID] {
                    let mechBikes = stationInfo.0
                    let ebikes = stationInfo.1
                    let docks = stationInfo.2
                    let totalBikes = mechBikes + ebikes
                    
                    DispatchQueue.main.async {
                        self.stationNameLabel.setText(self.stationName)
                        self.availableBikesLabel.setText("\(totalBikes)")
                        self.availableDocksLabel.setText("\(docks)")
                        self.map.addAnnotation(self.coordinates, with: .red)
                    }
                }
            }
        }
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
