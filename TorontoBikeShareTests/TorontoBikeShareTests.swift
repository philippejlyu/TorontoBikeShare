//
//  TorontoBikeShareTests.swift
//  TorontoBikeShareTests
//
//  Created by Philippe Yu on 2020-08-11.
//  Copyright © 2020 PhilippeYu. All rights reserved.
//

import XCTest
import TorontoBikeShare
import Pods_TorontoBikeShare

class TorontoBikeShareTests: XCTestCase {
    
    var stations: [BikeStation] = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        for i in 0..<30 {
            let newStation = BikeStation(name: "\(i)", stationID: "\(i)", lat: 0, lon: 0, availableBikes: 0, availableEbike: 0, availableDock: 0, distance: Double(40 - i))
            self.stations.append(newStation)
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSorting() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let nearby = FindNearby(locations: stations)
        let result = nearby.findNearestStations()
        XCTAssert(result[0].distance == 11, "\(result[0].distance)")
        
        for i in 0..<30 {
            let number = result[i].distance
            XCTAssert(number == Double(i + 11))
        }
        
    }


}
