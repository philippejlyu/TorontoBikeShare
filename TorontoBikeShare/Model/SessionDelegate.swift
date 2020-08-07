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
}
