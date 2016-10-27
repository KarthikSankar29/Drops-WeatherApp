//
//  WMUtility.swift
//  WeatherApp
//
//  Created by karthik_sa on 10/21/16.
//  Copyright © 2016 KarthikSankar. All rights reserved.
//
import UIKit

class WMUtility: NSObject {
  /** 
   Class Function to save Last searched location
     - Parameter 
      - locationString : location name needs to be saved
  */
  class func saveLastLocation(locationString: String) {
    let defaults = UserDefaults.standard
    let savedPlace = getLastSearchedLocation()
    if savedPlace != nil {
      if savedPlace == locationString {
        return
      }
      defaults.set(locationString, forKey: "lastSearched")
    }
    defaults.set(locationString, forKey: "lastSearched")
  }
  /**
   Class function to return last searched location
     - Return - location from defaults
  */
  class func getLastSearchedLocation() -> String! {
    let defaults = UserDefaults.standard
    if let location = defaults.string(forKey: "lastSearched") {
      return location
    }
    return nil
  }
}

// MARK : View Controller Extension
extension UIViewController {
  // Show Alert in View Controller
  func showAlert(title: String, message: String) {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
