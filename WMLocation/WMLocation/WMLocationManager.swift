//
//  WMLocationManager.swift
//  WMLocation
//  Class to fetch user current location
//
//  Created by karthik_sa on 10/21/16.
//  Copyright © 2016 Photon Infotech Inc. All rights reserved.
//

import CoreLocation

/**
 Location Error Enums
*/
public enum WMLocationError: Error {
  case userDenied               // User Denied Location Access in prompt
  case locationAccessError      // Location Access Error
  case internetOffline          // Network Connection is Offline
  case noError                  // No Error used for success response
}

open class WMLocationManager: NSObject {
  
  open static let sharedInstance = WMLocationManager()    // Singleton Class
  var locationManager:CLLocationManager!                  // Location Manager
  public var baseViewController: UIViewController!        // Base View Controller
    
  let locationErrorTitle = "Location Access Disabled"           // Location Disabled Title
  let locationErrorMessage = "Please Turn On Location Services From Settings App." // Location Disabled Message
  
  // Completion Handler for Location Fetch
  var completionHandler:(_ currentLocation: CLLocation?,_ error: WMLocationError) -> Void = { location , error in }
  
  private override init() {}      // Initialization
  
  /**
   Configure Location Manager by setting delegate and accuracy
   
   - Parameters:
      - withBaseViewController: View Controller from which Location Manager was triggered.
   */
  public func configLocationManager(withBaseViewController: UIViewController) {
    // CLLocation Instance
    self.locationManager = CLLocationManager()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    // Set Base View Controller
    self.baseViewController = withBaseViewController
  }
  
  /**
   Returns users current location else returns error in WMLocationError format
   
   - Returns:
      - onLocationFetch: completionBlock with current location and error
  */
  public func getCurrentLocation(onLocationFetch:@escaping (_ currentLocation: CLLocation?,_ error: WMLocationError) -> Void) {
      completionHandler = onLocationFetch
    
    // Check for Autherisation Status
    switch CLLocationManager.authorizationStatus() {
      case .notDetermined:
        // Request for Access as first time user
        self.locationManager.requestWhenInUseAuthorization()
      case .authorizedAlways, .authorizedWhenInUse:
        // Get users location
        self.getUserLocation()
      case .denied , .restricted:
        // Send Error for user denied
        // Show Settings Alert to User
        showSettingsAlert()
        completionHandler(nil,.userDenied)
    }
  }
  
  /**
   Fetch User Location from Location Manager
 */
  public func getUserLocation() {
    // Check for Location Access
    self.locationManager.requestLocation()
  }
}

// MARK: - CLLocation Manager Delegate
extension WMLocationManager : CLLocationManagerDelegate {
  /**
   Delegate Callback for each location fetch callback from location manager
 */
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Get First Location Coordinates
    if let location = locations.first {
      // Return Success and location data
      completionHandler(location, .noError)
      self.locationManager.stopUpdatingLocation()     // Stop Updating Location
    }
    else {
      completionHandler(nil,.locationAccessError)     // Return Location Error
    }
  }
  
  /** 
    Location Fetch Failed
 */
 public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    completionHandler(nil,.locationAccessError)       // Return Location Error
  }
  
  /**
    Location Authorization Status Change Delegate Callbacks
 */
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // Current Status
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      // Get User Location
      self.getUserLocation()
    case .notDetermined, .denied, .restricted :
      // Show Settings Alert
      showSettingsAlert()
      completionHandler(nil, .userDenied)
    }
  }
  
  /**
      Shows Settings and Cancel button in alert to help user to open Settings App, 
    when location is disabled
 */
  func showSettingsAlert() {
    // Show Alert View Controller
    let alertController = UIAlertController(
      title: locationErrorTitle,
      message: locationErrorMessage,
      preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
      if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.shared.openURL(url as URL)
      }
    }
    alertController.addAction(openAction)
    // In Base View Controller
    self.baseViewController.present(alertController, animated: true, completion: nil)
  }
}
