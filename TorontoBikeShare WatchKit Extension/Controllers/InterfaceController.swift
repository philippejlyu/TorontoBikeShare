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
    var station: BikeStation! = nil

    // MARK: - Outlets
    @IBOutlet weak var stationNameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var availableBikesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var availableDocksLabel: WKInterfaceLabel!
    
    @IBOutlet weak var map: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupInfo(context)
        fetchData()
    }
    
    // MARK: - View setup
    /// Adds the station name, marker on the map, and centers the map
    fileprivate func setupInfo(_ context: Any?) {
        if let station = context as? BikeStation {
            self.station = station
            let coordinates = CLLocationCoordinate2D(latitude: station.lat, longitude: station.lon)
            self.centerMapOnCoordinates(coordinates)
            self.addMarkerToMap(coordinates)
            self.stationNameLabel.setText(self.station.name)
        }
    }
    
    fileprivate func fetchData() {
        let fetcher = DataFetcher()
        fetcher.populateBikes { (bikes, error) in
            if error == nil {
                if let stationInfo = bikes?[self.station.stationID] {
                    print(stationInfo)
                    let mechBikes = stationInfo.0
                    let ebikes = stationInfo.1
                    let docks = stationInfo.2
                    let totalBikes = mechBikes + ebikes
                    
                    DispatchQueue.main.async {
                        self.availableBikesLabel.setText("\(totalBikes)")
                        self.availableDocksLabel.setText("\(docks)")
                    }
                }
            }
        }
    }
    
    // MARK: - Map related functions
    private func centerMapOnCoordinates(_ coordinates: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        self.map.setRegion(MKCoordinateRegion(center: coordinates, span: span))
    }
    
    private func addMarkerToMap(_ coordinates: CLLocationCoordinate2D) {
        self.map.addAnnotation(coordinates, with: .purple)
    }
}
