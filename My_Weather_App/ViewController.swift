//
//  ViewController.swift
//  My_Weather_App
//
//  Created by Mohsen Abdollahi on 5/28/19.
//  Copyright © 2019 Mohsen Abdollahi. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    
    //Declare instance variables
    let locationmanager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.startUpdatingLocation()
    }
    
    
    //MARK: - Location Manager Delegate Method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationmanager.stopUpdatingLocation()
            print("Longtitude = \(location.coordinate.longitude) , latitude = \(location.coordinate.latitude)")
            
            let longtitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    


}

