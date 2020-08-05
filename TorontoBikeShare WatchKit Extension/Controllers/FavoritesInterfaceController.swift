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

    @IBOutlet weak var favoritesTable: WKInterfaceTable!
    
    var favorites: [NSDictionary] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
//        print(self.documentsDirectory())
        //self.favorites = self.readFromPlist()!
        self.favoritesTable.setNumberOfRows(self.favorites.count, withRowType: "favoriteRow")
        
        setupTable()
        
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Table related
    
    func setupTable() {
        for index in 0..<self.favoritesTable.numberOfRows {
            guard let controller = favoritesTable.rowController(at: index) as? FavoritesRowController else { continue }
            controller.initializeInformation(information: self.favorites[index])
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let station = self.favorites[rowIndex]
        pushController(withName: "StationInferface", context: station)

    }
    
    // MARK: - Reading
    func readFromPlist() -> [NSDictionary]? {

        if let path = Bundle.main.path(forResource: "Favorites", ofType: "plist"), let favorites = NSArray(contentsOfFile: path) as? [NSDictionary] {
            
            return favorites
        }
        return nil
    }
    
//    func documentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: <#T##FileManager.SearchPathDomainMask#>)
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
//
//    func dataFilePath() -> URL {
//        return documentsDirectory().appendingPathComponent("Favourites.plist")
//    }

}
