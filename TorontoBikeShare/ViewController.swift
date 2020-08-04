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
        let fetcher = DataFetcher()
        self.registerMapAnnotationViews()
        fetcher.getLocations { (locations, error) in
            if let locations = locations {
                self.bikeLocations = locations
                let keys = locations.keys
                for key in keys {
                    let loc = locations[key]!
                    // We want to add an annotation for each one
                    let annotation = BikeAnnotation(coordinate: loc.coordinate)
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
    
    /// Handles what happens when the annotation button is clicked
    
    @objc func buttonClicked(sender: FavoriteButton) {
        print("button clicked")
        let annotation = sender.annotation as! BikeAnnotation
        if annotation.isFavorite {
            sender.setImage(UIImage(systemName: "star"), for: .normal)
            annotation.isFavorite = false
        } else {
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            annotation.isFavorite = true
            let station = annotation.station!
            self.favoriteLocations[station.name] = station
            
            // TODO: Save to file
        }
    }
    
    
    
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
    }
    
}

