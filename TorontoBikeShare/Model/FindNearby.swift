//
//  FindNearby.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-07.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import Foundation
import CoreLocation

class FindNearby: NSObject, CLLocationManagerDelegate {
    
    var locations: [BikeStation]
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var delegate: SortedLocationsDelegate?
    
    init(locations: [BikeStation]) {
        self.locations = locations
        super.init()
        self.requestCurrentLocation()
    }
    
    
    // MARK: - Core location
    func requestCurrentLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update location")
        guard let locValue = manager.location else { return }
        self.currentLocation = locValue
        for i in 0..<self.locations.count {
            guard let newStation = self.setStationDistance(station: self.locations[i]) else { continue }
            self.locations[i] = newStation
        }
        let nearby = self.findNearestStations()
        self.delegate?.didFinishSorting(locations: nearby)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    // MARK: - Data processing
    func findNearestStation() -> BikeStation {
        var nearest = self.locations[0]
        let tempLoc = CLLocation(latitude: nearest.lat, longitude: nearest.lon)
        var nearestDistance = self.currentLocation!.distance(from: tempLoc)
        
        for location in self.locations {
            let stationLocation = CLLocation(latitude: location.lat, longitude: location.lon)
            let distance = self.currentLocation!.distance(from: stationLocation)
            if distance < nearestDistance {
                nearest = location
                nearestDistance = distance
            }
        }
        
        return nearest
    }
    
    /// Sets the bike station distance, then returns the new object
    func setStationDistance(station: BikeStation) -> BikeStation? {
        let stationLocation = CLLocation(latitude: station.lat, longitude: station.lon)
        guard let current = self.currentLocation else { return nil }
        let distance = current.distance(from: stationLocation)
        var newStation = station.copy()
        newStation.distance = distance
        return newStation
    }
    
    /// Returns an array of bike stations in sorted order based on the distance from the users location
    func findNearestStations() -> [BikeStation] {
        return self.locations.sorted(by: { $0.distance < $1.distance })
    }
    
}

protocol SortedLocationsDelegate {
    func didFinishSorting(locations: [BikeStation])
}
