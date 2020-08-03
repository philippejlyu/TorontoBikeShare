//
//  ViewController.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-03.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!

    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fetcher = DataFetcher()
        fetcher.getLocations { (locations, error) in
            if let locations = locations {
                let keys = locations.keys
                for key in keys {
                    let loc = locations[key]!
                    print("\(loc.name), \(loc.availableBikes), \(loc.availableEbike), \(loc.availableDock)")
                }
            } else {
                print(error)
            }
        }
        
    }


}

