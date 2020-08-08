//
//  WatchCommunication.swift
//  TorontoBikeShare
//
//  Created by Philippe Yu on 2020-08-04.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import UIKit
import WatchConnectivity

class SessionDelegate: NSObject, WCSessionDelegate {
        
    var wcSession: WCSession! = nil
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation did complete: \(activationState == .activated), \(error?.localizedDescription)")
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
           print("Session did deactivate")
    }
    #endif

    
    // MARK: - User Info retreival
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        // We have received user info
        let persistence = FavoritePersistence()
        var favs = persistence.retrieveFavorites()
        // Safely unwrap the operation
        if let adding = userInfo["add"] as? Bool {
            // Get the bike station from user info
            guard let station = persistence.dictToBikeStation(dict: userInfo) else { return }
            // Send the proper notification depending on the operation being done
            if adding {
                // Add it to be saved to the favourites plist
                favs[station.stationID] = station
                persistence.saveAllToPlist(locations: favs)
                NotificationCenter.default.post(name: Notification.Name("stationAdded"), object: station)
            } else {
                // Remove it then save to the favourites plist
                favs[station.stationID] = nil
                persistence.saveAllToPlist(locations: favs)
                NotificationCenter.default.post(name: Notification.Name("stationRemoved"), object: station)
            }
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("Did finish user info transfer")
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - File transfer
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        
        // Save the file
        let tempURL = file.fileURL
        let fileManager = FileManager.default
        let favoritePersistence = FavoritePersistence()
        do {
            let path = favoritePersistence.dataFilePath()
            // First we have to delete the file that was there before
            print(path.absoluteString)
            print(path)
            if fileManager.fileExists(atPath: path.path) {
                // Delete it
                print("File exists there, going to remove it")
                try fileManager.removeItem(at: favoritePersistence.dataFilePath())
            } else {
                print("File does not exist there")
                
            }
            
            // Now that there isn't file there, we can move it there
            try fileManager.moveItem(at: tempURL, to: favoritePersistence.dataFilePath())
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        // Now check to see what changed so we can send a notification to the observer
        guard let userInfo = file.metadata else { return }
        
        let persistence = FavoritePersistence()
        // Safely unwrap the operation
        if let adding = userInfo["add"] as? Bool {
            // Get the bike station from user info
            guard let station = persistence.dictToBikeStation(dict: userInfo) else { return }
            // Send the proper notification depending on the operation being done
            if adding {
                // Add it to be saved to the favourites plist
                NotificationCenter.default.post(name: Notification.Name("com.philippeyu.bike.stationAdded"), object: station)
            } else {
                // Remove it then save to the favourites plist
                NotificationCenter.default.post(name: Notification.Name("com.philippeyu.bike.stationRemoved"), object: station)
            }
        }
        
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("Did finish transfering file")
        if error != nil {
            print("Error transferring file: \(error?.localizedDescription)")
        }
    }
}
