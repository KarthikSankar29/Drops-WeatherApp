//
//  WMWeatherManager.swift
//  WMServices
//
//  Class used to fetch weather data from Open Weather Map API
//
//  Created by Karthik S on 21/10/16.
//  Copyright © 2016 KarthikSankar. All rights reserved.
//

import Foundation
import SystemConfiguration

// OpenWeatherMap.org : Weather API Key
let openWeatherAPIKey = "7189fb0436552a1844eed2a55a8305e8"
let baseAPIURL = "http://api.openweathermap.org/data/2.5/"

/**
 Weather Error Enums
*/
public enum WMWeatherError: Error {
  case modelError           // Model Error
  case serverTimeout        // Server Timeout
  case serverError          // Server Error
  case internetOffline      // Internet Offline
  case noError              // No Error
  case noCityFound          // City Not Found
}

/** 
 Weather Icon Code Enums
*/
public enum WMWeatherCode: String {
  case clear = "Clear"        // Clear Weather
  case cloud = "Cloud"        // Cloudy Weather
  case lighting = "Lighting"  // Lighting Weather
  case rain = "Rain"          // Rainy Weather
  case snow = "Snow"          // Snowy Weather
  case wind = "Wind"          // Windy Weather
}

/**
 Weather Unit Enums
*/
public enum WMWeatherUnit: String {
  case Fahrenheit = "imperial"      // Farenheit Unit
  case Celsius = "metric"           // Celsius Unit
}

open class WMWeatherManager: NSObject {
  // Singleton Object
  open static let sharedInstance = WMWeatherManager()
  private override init() {}        // Initialization
  // Weather Unit
  public var weatherUnit: WMWeatherUnit = .Fahrenheit          // Default Weather Unit
  /**
   Returns weather data from open weather api by passing latitude and longitude
   
   - Parameters:
      - latitude  : Latitude
      - longitude : Longitude
      - onComplete: Completion Block
      - onError   : Error Block
 */
  public func getTodaysWeatherData(latitude: Double,
                                longitude: Double,
                                onComplete:@escaping (_ reponse: WMWeatherResponseModel) -> Void,
                                onError:@escaping (_ error: WMWeatherError) -> Void) {
    // Check for network connectivity
    if !Reachability.isConnectedToNetwork() {
      onError(.internetOffline)
      return
    }
    // Generate Request URL
    var request = URLRequest(url: NSURL(string: baseAPIURL+"weather?APPID=\(openWeatherAPIKey)&lat=\(latitude)&lon=\(longitude)&units=\(weatherUnit.rawValue)") as! URL)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Process Task
    let task = URLSession.shared.dataTask(with: request) {
      (data, response, error) in
      
      // Check for Server Error
      guard error == nil else {
        onError(.serverError)     // Throw Server Error
        return
      }
      
      // Check for Data
      guard let responseData = data else {
        onError(.serverError)   // Throw Server Error
        return
      }
      
      // Convert Response Data to Json
      do {
        let jsonResult = try JSONSerialization.jsonObject(with: responseData, options:
          JSONSerialization.ReadingOptions.allowFragments)
        // Convert Json to Model
        let responseModel = WMWeatherResponseModel(jsonDictionary: jsonResult as! [String : Any])
        #if DEBUG
          if let responseJSONString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
            print("Current Weather Response :\(responseJSONString)")
          }
        #endif
        onComplete(responseModel)
      } catch {
        onError(.modelError)        // Throw Model Error
        return
      }
    }
    task.resume()
  }
  
  /**
        Process Forecase Request and returns weather data
    - Parameters
        - request : URLRequest Object
        - onComplete : Completion block
        - onError :  Error block
  */
  func processForcastRequest(request: URLRequest,
                             onComplete:@escaping (_ reponse: WMForecastResponseModel) -> Void,
                             onError:@escaping (_ error: WMWeatherError) -> Void) {
    let task = URLSession.shared.dataTask(with: request) {
      (data, response, error) in
      
      // Check for Server Error
      guard error == nil else {
        onError(.serverError)
        return
      }
      
      // Check for Data
      guard let responseData = data else {
        onError(.serverError)
        return
      }
      
      // Convert Response Data to Json
      do {
        let jsonResult = try JSONSerialization.jsonObject(with: responseData, options:
          JSONSerialization.ReadingOptions.allowFragments)
        
        // Check for City Not Found
        if self.isCityFound(jsonResult: jsonResult as! [String : Any]) == false {
            onError(.noCityFound)
            return
        }

        // Convert Json to Model
        let responseModel = WMForecastResponseModel(jsonDictionary: jsonResult as! [String : Any])
        #if DEBUG
          if let responseJSONString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
            print("Forcast Response :\(responseJSONString)")
          }
        #endif
        onComplete(responseModel)
      } catch {
        onError(.modelError)
        return
      }
    }
    task.resume()
  }

  /**
    Check is City is Found
     
    - Returns  : true if city is valid
  */
  func isCityFound(jsonResult: [String:Any]) -> Bool {
    if jsonResult.index(forKey: "cod") != nil {
      if (jsonResult["cod"]! as! String) == "502" {
        return false
      }
    }
    return true
  }

  /**
    Returns Forecast data of given lat and long
    - Parameters :
        - latitude : Latitude
        - longitude : Longitude
        - onComplete : Completion Block
        - OnError : Error Block
  */
  public func getForcastData(latitude: Double,
                                   longitude: Double,
                                   onComplete:@escaping (_ reponse: WMForecastResponseModel) -> Void,
                                   onError:@escaping (_ error: WMWeatherError) -> Void) {
    
    // Check for network connectivity
    if !Reachability.isConnectedToNetwork() {
      onError(.internetOffline)
      return
    }
    let requestUrl:NSURL! = NSURL(string: baseAPIURL+"forecast/daily?APPID=\(openWeatherAPIKey)&lat=\(latitude)&lon=\(longitude)&units=\(weatherUnit.rawValue)&cnt=5")
    // Check for Valid URL
    if requestUrl == nil {
      onError(.serverError)
      return
    }
    // Request
    var request = URLRequest(url:requestUrl as URL!)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Process Forecast Request
    processForcastRequest(request: request, onComplete: { (responseModel) in
      onComplete(responseModel)
      }) { (error) in
        onError(error)
    }
  }
  
/**
 Get Forecast Data by City Name
 - Parameters
    - cityName : Name of City
    - onComplete : Completion Block
    - onError : Error Block
 */
  public func getForcastData(cityName: String,
                             onComplete:@escaping (_ reponse: WMForecastResponseModel) -> Void,
                             onError:@escaping (_ error: WMWeatherError) -> Void) {
    
    // Check for network connectivity
    if !Reachability.isConnectedToNetwork() {
      onError(.internetOffline)
      return
    }
    // Request
    let requestUrl:NSURL! = NSURL(string: baseAPIURL+"forecast/daily?APPID=\(openWeatherAPIKey)&q=\(cityName)&units=\(weatherUnit.rawValue)&cnt=5")
    // Check for Valid URL 
    if requestUrl == nil {
      onError(.serverError)
      return
    }
    var request = URLRequest(url:requestUrl as URL!)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    processForcastRequest(request: request, onComplete: { (responseModel) in
      onComplete(responseModel)
    }) { (error) in
      onError(error)
    }
  }
}


// MARK: Open Weather Map Response Model
open class WMWeatherResponseModel {
  
  public var place = ""                 // City Name
  public var humidity = 0.0             // Humidity
  public var pressure = 0.0             // Pressure
  public var temp = 0                   // Avg Temperature
  public var temp_max = 0               // Today's Highest Temperature
  public var temp_min = 0               // Today's Lowest Temperature
  public var weatherDescription = ""    // Weather Description
  public var weatherId = 0              // Weather Id
  
  // Map Json String
  init(jsonDictionary: [String:Any]) {
    self.place = jsonDictionary["name"] as! String? ?? ""
    self.humidity = (jsonDictionary["main"] as! [String:Any])["humidity"]! as? Double ?? 0.0
    self.pressure = (jsonDictionary["main"] as! [String:Any])["pressure"]! as? Double ?? 0.0
    self.temp = ((jsonDictionary["main"] as! [String:Any])["temp"]! as? Int)! 
    self.temp_max = (jsonDictionary["main"] as! [String:Any])["temp_max"]! as! Int 
    self.temp_min = ((jsonDictionary["main"] as! [String:Any])["temp_min"]! as? Int)! 
    self.weatherId = (jsonDictionary["weather"] as! [AnyObject]).last!["id"]!! as? Int ?? 0
    self.weatherDescription = (jsonDictionary["weather"] as! [AnyObject]).last!["description"]!! as? String ?? ""
  }
}

// MARK: Forecast Model
open class WMForecastResponseModel {
  
  public var place = ""                         // Place
  public var lists = [WMForecastList]()         // List of Forcasts
  
  init(jsonDictionary: [String:Any]) {
    self.place = (jsonDictionary["city"] as! [String:Any])["name"]! as! String 
    // Temp Variable
    let tempVar = jsonDictionary["list"] as! [[String:Any]]
    for (_,element) in tempVar.enumerated() {
      let list = WMForecastList(jsonDictionary: element)
      lists.append(list)
    }
  }
}

open class WMForecastList {
  var dateUnit:Double = 0           // Date in UNIX TimeStamp
  public var temp = ""              // Average Current Temperature
  public var temp_max = ""          // Highest Current Temperature
  public var temp_min = ""          // Lowest Today's Temperatur
  public var pressure = 0.0         // Pressure
  public var humidity = 0.0         // Humidity
  public var weatherDescription = ""    // Weather Description
  public var weatherImage = ""          // Weather Image
  public var dayString = ""             // Day String
  public var dateString = ""            // Date String
  public var isToday = false            // Returns if its today
  
  // Open Weather Map API Codes
  var clearWeatherCode = ["800"]
  var cloudyWeatherCode = ["801","802","803","804"]
  var lightingWeatherCode = ["200","201","202","210","211","212","221","230","231","232"]
  var rainWeatherCode = ["300","301","302","310","311","312","313","314","321","500","501","502","503","504","511","520","521","522","531"]
  var snowWeatherCode = ["600","601","602","611","612","615","616","620","621","622"]
  var windWeatherCode = ["701","711","721","731","741","751","761","762","771","781"]
  
  init(jsonDictionary: [String:Any]) {
    self.dateUnit = jsonDictionary["dt"] as? Double ?? 0
    self.humidity = (jsonDictionary["humidity"] as? Double)! 
    self.pressure = jsonDictionary["pressure"] as? Double ?? 0.0
    self.temp = "\(round(((jsonDictionary["temp"] as! [String:Any])["day"]! as? Double)! ))°\(getUnitString())"
    self.temp_max = "\(round((jsonDictionary["temp"] as! [String:Any])["max"]! as? Double ?? 0))"
    self.temp_min = "\(round(((jsonDictionary["temp"] as! [String:Any])["min"]! as? Double)! ))"
    self.weatherImage = getWeatherImageFor(weatherId:((jsonDictionary["weather"] as! [AnyObject]).last!["id"]!! as? Int)! )
    self.weatherDescription = (jsonDictionary["weather"] as! [AnyObject]).last!["description"]!! as? String ?? ""
    
    let date = NSDate(timeIntervalSince1970: self.dateUnit)
    let calendar = NSCalendar.current
    let components = calendar.dateComponents([.day,.month,.year], from: date as Date)
    
    let year =  components.year
    let month = components.month
    let day = components.day
    
    dateString = "\(day!)"
    dayString = "\(month!),\(year!)"
    isToday = NSCalendar.current.isDateInToday(date as Date)
  }
  
  // Check for Unit String
  func getUnitString() -> String {
    switch WMWeatherManager.sharedInstance.weatherUnit {
    case .Celsius:
      return "C"
    case .Fahrenheit:
      return "F"
    }
  }
  
  // Get Weather Image File String
  func getWeatherImageFor(weatherId:Int) -> String {
    let weatherIdString = "\(weatherId)"
    let dayString = isDayString()
    // Check in which array weather code is mapped
    if self.clearWeatherCode.contains(weatherIdString) {
      return "\(WMWeatherCode.clear.rawValue)_\(dayString)"
    }
    else if self.cloudyWeatherCode.contains(weatherIdString) {
      return "\(WMWeatherCode.cloud.rawValue)_\(dayString)"
    }
    else if self.lightingWeatherCode.contains(weatherIdString) {
      return "\(WMWeatherCode.lighting.rawValue)_\(dayString)"
    }
    else if self.rainWeatherCode.contains(weatherIdString) {
      return "\(WMWeatherCode.rain.rawValue)_\(dayString)"
    }
    else if self.snowWeatherCode.contains(weatherIdString) {
      return "\(WMWeatherCode.snow.rawValue)_\(dayString)"

    }
    else if self.windWeatherCode.contains(weatherIdString) {
      return "\(WMWeatherCode.wind.rawValue)_\(dayString)"
    }
    return "\(WMWeatherCode.clear.rawValue)_\(dayString)"
  }
  
  // Get Day String
  func isDayString() -> String {
    let date = NSDate()
    let calendar = NSCalendar.current
    let components = calendar.dateComponents([.hour], from: date as Date)
    
    let hour =  components.hour!
    
    if (hour > 6) && (hour < 18) {
      return "Day"
    }
    return "Night"
  }
}

// MARK: Reachability
public class Reachability {
  
  // Check for connectivity
  class func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    
    let isReachable = flags == .reachable
    let needsConnection = flags == .connectionRequired
    
    return isReachable && !needsConnection
  }
}

