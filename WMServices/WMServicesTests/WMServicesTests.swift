//
//  WMServicesTests.swift
//  WMServicesTests
//
//  Created by Karthik S on 21/10/16.
//  Copyright © 2016 KarthikSankar. All rights reserved.
//

import XCTest
@testable import WMServices

class WMServicesTests: XCTestCase {
    
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
        Test to check forecast details by cityname
    */
    func testGetForcastDataWithValidCityName() {
        // Create Weather Manager
        let weatherManager = WMWeatherManager.sharedInstance
        
        let fetchWeatherExpectation = expectation(description: "focastFecthWithValidCityName")
        
        let testCity = "Chennai"                // Test City
        
        weatherManager.getForcastData(cityName: testCity, onComplete: { (responseModel) in
            // Test for success
            XCTAssert(true, "Forecast Data Fetch Success")
            
            fetchWeatherExpectation.fulfill()
            }) { (error) in
            XCTAssert(false, "Forecast Data Fetch Failed")
            
            fetchWeatherExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("Forcast Fetch Test Failed : \(error)")
            }
        }
    }
    
    /**
        Test to check forecast details by invalid city name
    */
    func testGetForcastDataWithInValidCityName () {
        // Create Weather Manager
        let weatherManager = WMWeatherManager.sharedInstance
        
        let fetchWeatherExpectation = expectation(description: "focastFecthWithInvalidCityName")
        
        let testCity = "InValidCityName"                // Test City Name
        
        weatherManager.getForcastData(cityName: testCity, onComplete: { (responseModel) in
            // Test for success
            XCTAssert(true, "Forecast Data Fetch Success")
            
            fetchWeatherExpectation.fulfill()
        }) { (error) in
            XCTAssert(false, "Forecast Data Fetch Failed")
            
            fetchWeatherExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("Forcast Fetch Test Failed : \(error)")
            }
        }
    }
    
    /**
        Test to check Todays weather data
     */
    func testGetTodaysWeatherData() {
        // Create Weather Manager
        let weatherManager = WMWeatherManager.sharedInstance
        
        let fetchWeatherExpectation = expectation(description: "todaysWeatherFetchWithLatLong")
        
        let testLatitude    =   32.776664               // Test Latitude
        let testLongitude   =   -96.796988              // Test Longitude
        
        weatherManager.getTodaysWeatherData(latitude: testLatitude, longitude: testLongitude, onComplete: { (response) in
                // Test for success
                XCTAssert(true, "Todays Weather Data Fetch Success")
                fetchWeatherExpectation.fulfill()
            }) { (error) in
                XCTAssert(false, "Todays Weather Data Fetch Failed")
                fetchWeatherExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("Todays Weather Test Failed : \(error)")
            }
        }
    }
    
    /**
        Test to check forecast for lat long
    */
    func testGetForcastForLatLong() {
        // Create Weather Manager
        let weatherManager = WMWeatherManager.sharedInstance
        
        let fetchWeatherExpectation = expectation(description: "forecastFetchWithLatLong")
        
        let testLatitude    =   32.776664               // Test Latitude
        let testLongitude   =   -96.796988              // Test Longitude
        
        weatherManager.getForcastData(latitude: testLatitude, longitude: testLongitude, onComplete: { (response) in
            // Test for success
            XCTAssert(true, "Forecast Data Fetch Success")
            fetchWeatherExpectation.fulfill()
            }) { (error) in
                XCTAssert(false, "Forecast Data Fetch Failed")
                fetchWeatherExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("Forcast Fetch Test Failed : \(error)")
            }
        }
    }
}
