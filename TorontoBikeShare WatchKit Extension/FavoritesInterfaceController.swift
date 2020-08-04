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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.readFromPlist()
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
    
    // MARK: - Reading
    func readFromPlist() {
        print("going to read from plist")
//        Bundle.main.url(forResource: "Favorites", withExtension: "plist")
        if let path = Bundle.main.path(forResource: "Favorites", ofType: "plist"), let favorites = NSArray(contentsOfFile: path) as? [NSDictionary] {
            
            for index in favorites {
                print(index["station name"])
                print(index)
            }
        }
    }

}
