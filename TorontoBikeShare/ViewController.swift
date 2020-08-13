//
//  ViewController.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import UIKit
import MapKit
import WatchConnectivity

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
        let persistence = FavoritePersistence()
        self.favoriteLocations = persistence.retrieveFavorites()
        // Do this just in case it has never sent the data until now
        if !UserDefaults.standard.bool(forKey: "hasSentData") {
            persistence.sendPlistFileToWatch(locations: self.favoriteLocations, changedStation: nil, add: false)
            UserDefaults.standard.setValue(true, forKey: "hasSentData")
        }
        print(self.favoriteLocations)
        self.registerMapAnnotationViews()
        self.centerMapOnStation()
        addMapAnnotations()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showCompanionAppError()
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
            let bikeAnnotation = annotation as! BikeAnnotation
            if bikeAnnotation.isFavorite {
                favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
            favoriteButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
            markerAnnotationView.rightCalloutAccessoryView = favoriteButton
        }
        
        return annotationView
    }
    
    /// Handles what happens when the favorite button is clicked in the annotation
    @objc func buttonClicked(sender: FavoriteButton) {
        print("button clicked")
        let annotation = sender.annotation as! BikeAnnotation
        let persistence = FavoritePersistence()
        if annotation.isFavorite {
            sender.setImage(UIImage(systemName: "star"), for: .normal)
            annotation.isFavorite = false
            let id = annotation.station!.stationID
            self.favoriteLocations.removeValue(forKey: id)
//            persistence.saveAllToPlist(locations: self.favoriteLocations)
            
            // Now send the change to the apple watch
            persistence.sendPlistFileToWatch(locations: self.favoriteLocations, changedStation: annotation.station!, add: false)
            
        } else {
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            annotation.isFavorite = true
            let station = annotation.station!
            self.favoriteLocations[station.stationID] = station
            
            // Now add this location to the apple watch
            persistence.sendPlistFileToWatch(locations: self.favoriteLocations, changedStation: annotation.station!, add: true)
        }
    }
    
    private func centerMapOnStation() {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center = CLLocationCoordinate2D(latitude: 43.661543, longitude: -79.393332)
        self.mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
    }
    
    /// Register the required annotation views for map annotations
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
    }
    
    /// Gets the bike locations from the city's server
    fileprivate func addMapAnnotations() {
        let fetcher = DataFetcher()
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
                    if self.favoriteLocations[loc.stationID] != nil {
                        // It is favorited, so we need to do something about it
                        annotation.isFavorite = true
                        // We change the fill of the button in map view for annotation
                    }
                    
                    self.mapView.addAnnotation(annotation)
                    
                }
            } else {
                print(error)
            }
        }
    }
    
    // MARK: - Watch related
    
    /// Shows an error if the watch app is not installed
    func showCompanionAppError() {
        let session = WCSession.default
        print(session.isWatchAppInstalled)
        if !session.isWatchAppInstalled {
            print("Watch app is not installed")
            let alert = UIAlertController(title: "Watch app not installed", message: "The watch app should be installed for BikeShare to work properly", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

