//
//  WMHomeViewController.swift
//  WeatherApp
//
//  Created by Karthik S on 21/10/16.
//  Copyright © 2016 KarthikSankar. All rights reserved.
//

import UIKit
import WMLocation
import WMServices

class WMHomeViewController: UIViewController {
    
    @IBOutlet weak var weatherDataTableView: UITableView!     // Table View
    @IBOutlet weak var placeTextField: UITextField!           // Place Text Field
    @IBOutlet weak var savedContainer: UIView!                // Last Saved Container View
    
    let locationManager = WMLocationManager.sharedInstance    // Location Manager
    let weatherManager = WMWeatherManager.sharedInstance      // Weather Manager
    
    @IBOutlet weak var lastSearchedButton: UIButton!                    // Search Button
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!      // Activity Indicator
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!       // Constraint
    
    var forcasts = [WMForecastList]()                                   // Forcases List
    var currentPlace = ""                                               // Current Place
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Config Weather Manager
        weatherManager.weatherUnit = .Celsius
        // Hide Weather Data
        self.weatherDataTableView.isHidden = true
        self.activityIndicator.isHidden = true
        // Check for Last Searched
        refreshLastSavedView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO : UI for getting current location weather
    // MARK: Current Weather Fetch
    func getCurrentWeatherDataForCurrentLocation() {
        // Config Location Manager
        locationManager.configLocationManager(withBaseViewController: self)
        
        // Fetch current location
        locationManager.getCurrentLocation { (currentLocation, error) in
            // Check if current location is available
            if currentLocation == nil {
                // Error Occured
                return
            }
            else {
                // Get Forecast for current location
                self.getForcastFor(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!)
            }
        }
    }
    
    // Tapped on Last Searched Button
    @IBAction func lastSearchTapped(_ sender: AnyObject) {
        getForcastFor(place: ((sender as! UIButton).titleLabel?.text!)!)
    }
    
    @IBAction func getWeatherForCurrentLocation(_ sender: AnyObject) {
        getCurrentWeatherDataForCurrentLocation()
    }
    
    // Refresh View for Last Searched option
    func refreshLastSavedView() {
        let lastSearched = WMUtility.getLastSearchedLocation()      // Get Place from last searched
        if lastSearched != nil {
            self.savedContainer.isHidden = false
            // Set Button Title
            self.lastSearchedButton.setTitle(lastSearched, for: UIControlState.normal)
            self.lastSearchedButton.setTitle(lastSearched, for: UIControlState.highlighted)
            self.lastSearchedButton.setTitle(lastSearched, for: UIControlState.selected)
        }
        else {
            // Hide Saved Container
            self.savedContainer.isHidden = true
        }
    }
    
    // Refesh View to load latest weather list
    func refreshView() {
        // Execute in main thread
        DispatchQueue.main.async {
            self.placeTextField.text = self.currentPlace
            self.refreshLastSavedView()
            self.weatherDataTableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.weatherDataTableView.isHidden = false
        }
    }
    
    // MARK: Weather Data Fetch
    func getForcastFor(latitude: Double,longitude: Double) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        // Get Forcast Data
        weatherManager.getForcastData(latitude: latitude, longitude: longitude, onComplete: { (weatherResponse) in
            // Save Forcast Data
            self.currentPlace = weatherResponse.place
            self.forcasts = weatherResponse.lists
            self.refreshView()
        }) { (error) in
            self.refreshView()
            // Error Occured
            switch error {
            case .internetOffline:
                self.showAlert(title: WMConstants.networkOfflineTitle, message: WMConstants.networkOfflineMessage)
                break
            case .serverError, .modelError ,.serverTimeout:
                self.showAlert(title: WMConstants.serverErrorTitle, message: WMConstants.serverErrorMessage)
                break
            case .noError:
                break
            case .noCityFound:
                self.showAlert(title: WMConstants.cityNotFoundTitle, message: WMConstants.cityNotFoundMessage)
                break
            }
        }
    }
    
    func getForcastFor(place: String) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        // Get Forcast Data
        weatherManager.getForcastData(cityName: place, onComplete: { (weatherResponse) in
            // Save Forcast Data
            self.currentPlace = weatherResponse.place
            self.forcasts = weatherResponse.lists
            self.refreshView()
        }) { (error) in
            self.refreshView()
            // Error Occured
            switch error {
            case .internetOffline:
                 self.showAlert(title: WMConstants.networkOfflineTitle, message: WMConstants.networkOfflineMessage)
                break
            case .serverError, .modelError ,.serverTimeout:
                self.showAlert(title: WMConstants.serverErrorTitle, message: WMConstants.serverErrorMessage)
                break
            case .noError:
                break
            case .noCityFound:
                self.showAlert(title: WMConstants.cityNotFoundTitle, message: WMConstants.cityNotFoundMessage)
                break
            }
        }
    }
}

// MARK : Table View Delegates
extension WMHomeViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forcasts.count      // Number of Weather Forecast Data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.weatherDataTableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WMTableViewCell
        // Config Cell
        configCell(currentCell: cell, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // Config Cell based on weather data
    func configCell(currentCell: WMTableViewCell,index:Int) {
        let currentWeatherData = self.forcasts[index]
        currentCell.humidityLabel.text = "\(currentWeatherData.humidity)"
        currentCell.weatherDescription.text = currentWeatherData.weatherDescription
        currentCell.weatherTemp.text = "\(currentWeatherData.temp)"
        currentCell.lowerTempLabel.text = "\(currentWeatherData.temp_min)"
        currentCell.upperTempLabel.text = "\(currentWeatherData.temp_max)"
        currentCell.dateLabel.text = currentWeatherData.dateString
        currentCell.dayLabel.text = currentWeatherData.dayString
        currentCell.todayMarker.isHidden = !currentWeatherData.isToday
        currentCell.weatherIcon.image = UIImage(named: currentWeatherData.weatherImage)
    }
}

// MARK : Text Field Delegate
extension WMHomeViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Execute additional code
        getForcastFor(place: textField.text!)
        WMUtility.saveLastLocation(locationString: self.placeTextField.text!)
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
}

