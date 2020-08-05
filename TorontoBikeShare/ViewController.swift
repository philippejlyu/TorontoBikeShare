//
//  ViewController.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    var bikeLocations: [String: BikeStation] = [:]
    var favoriteLocations: [String: BikeStation] = [:]
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!

    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.favoriteLocations = self.retrieveFavorites()
        print(self.favoriteLocations)
        let fetcher = DataFetcher()
        self.registerMapAnnotationViews()
        print(self.documentsDirectory())
        fetcher.getLocations { (locations, error) in
            if let locations = locations {
                self.bikeLocations = locations
                let keys = locations.keys
                for key in keys {
                    let loc = locations[key]!
                    // We want to add an annotation for each one
                    let coord = CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.lon)
                    let annotation = BikeAnnotation(coordinate: coord)
                    annotation.title = loc.name
                    annotation.station = loc
                    // TODO: Check to see if this place is favorited
                    
                    self.mapView.addAnnotation(annotation)
                    
                    print("\(loc.name), \(loc.availableBikes), \(loc.availableEbike), \(loc.availableDock)")
                }
            } else {
                print(error)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.delegate = self
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        let identifier = "AnnotationView"
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = annotationView as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.markerTintColor = UIColor.purple
            
            // Provide an image view to use as the accessory view's detail view.
            markerAnnotationView.detailCalloutAccessoryView = UIImageView(image: UIImage(systemName: "car.fill"))
            let favoriteButton = FavoriteButton(type: .detailDisclosure)
            favoriteButton.annotation = annotation
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
            markerAnnotationView.rightCalloutAccessoryView = favoriteButton
        }
        
        return annotationView
    }
    
    /// Encodes self.favoriteLocations to the favorite plist file on the iPhone
    fileprivate func encodeToPlist() {
        // This saves to a plist file in the documents directory of the iphone
        let encoder = PropertyListEncoder()
        do {
            let arr = self.processFavoriteLocations()
            let data = try encoder.encode(arr)
            try data.write(to: self.dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding or writing: \(error.localizedDescription)")
        }
    }
    
    /// Handles what happens when the annotation button is clicked
    
    @objc func buttonClicked(sender: FavoriteButton) {
        print("button clicked")
        let annotation = sender.annotation as! BikeAnnotation
        if annotation.isFavorite {
            sender.setImage(UIImage(systemName: "star"), for: .normal)
            annotation.isFavorite = false
            let id = annotation.station!.stationID
            self.favoriteLocations.removeValue(forKey: id)
            self.encodeToPlist()
        } else {
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            annotation.isFavorite = true
            let station = annotation.station!
            self.favoriteLocations[station.stationID] = station
            
            encodeToPlist()
        }
    }
    
    func processFavoriteLocations() -> [BikeStation] {
        var stations: [BikeStation] = []
        for key in self.favoriteLocations.keys {
            stations.append(self.favoriteLocations[key]!)
        }
        return stations
    }
    
    
    
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Favourites.plist")
    }
    
    // TODO: Add read from plist to recover saved places
    
    /// Retreives the favorites from the plist file on the iPhone
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
    
    /*
     
     if let station = context as? NSDictionary {
         self.stationID = station["station id"] as! String
         self.stationName = station["station name"] as! String
         let lat = station["lat"] as! Double
         let lon = station["lon"] as! Double
         self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
         print("Got the info populated")
     }
     */
    
}

