//
//  WMLocationTests.swift
//  WMLocationTests
//
//  Created by karthik_sa on 10/21/16.
//  Copyright © 2016 Photon Infotech Inc. All rights reserved.
//

import XCTest
@testable import WMLocation

class WMLocationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    /**
        Test to get current location
    */
    func testGetValidCurrentLocation () {
         // Create Location Manager
        let locationManager = WMLocationManager.sharedInstance
        
        let locationFetchExpectation = expectation(description: "LocationFetchTest")
        
        locationManager.getCurrentLocation { (currentLocation, error) in
            XCTAssertEqual(error, WMLocationError.noError)
            locationFetchExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("Location Fetch Test Failed : \(error)")
            }
            XCTFail("Location Fetch Timeout")
        }
    }
    /**
        Test to get invalid location data
    */
    func testGetInvalidCurrentLocation() {
        // Create Location Manager
        let locationManager = WMLocationManager.sharedInstance
        
        let locationFetchExpectation = expectation(description: "LocationFetchTest")
        
        locationManager.getCurrentLocation { (currentLocation, error) in
            XCTAssertNotEqual(error, WMLocationError.noError)
            locationFetchExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("Location Fetch Test Failed : \(error)")
            }
            XCTFail("Location Fetch Timeout")
        }
    }
}
