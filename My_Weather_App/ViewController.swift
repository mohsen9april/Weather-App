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
    let date = Date()
    let calendar = Calendar.current
    
    
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
 
    
    //Declare instance variables
    let locationmanager = CLLocationManager()
    let weatherdatamodel = WeatherDataModel()
    

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
            
            //let params: [String : String] = ["lat" : latitude, "long": longtitude, "appid": APP_ID]
            getWeatherData(lat : latitude , long: longtitude )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: - GetWeatherData From API
    func getWeatherData(lat: String , long: String){
    let WEATHER_URL1 = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=db492be2c9ffb3c34e5d05c39e837bf1"
        
        Alamofire.request(WEATHER_URL1).responseJSON { (response) in
            if response.result.isSuccess {
                print("SUCCESS! Got the weather data from API")
                //print(response)
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.ParsingWeatherData(json: weatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                //self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    //MARK: - Parsing Current Weather Data JSON Formant
    func ParsingWeatherData(json: JSON) {
        
        weatherdatamodel.city = json["name"].stringValue
        weatherdatamodel.temp = json["weather"][0]["main"].stringValue
        let result = json["main"]["temp"].doubleValue
        weatherdatamodel.temperature = Int(result - 273.15)
        weatherdatamodel.condition = json["weather"][0]["id"].intValue
        weatherdatamodel.weatherIconName = weatherdatamodel.updateWeatherIcon(condition: weatherdatamodel.condition)
        
        updateUIWeatherDataModel()

    }
    
    //MARK: - Update UI WeatherData
    func updateUIWeatherDataModel(){
        
        print(weatherdatamodel.city)
        cityLabel.text = weatherdatamodel.city
        
        print(weatherdatamodel.temp)
        tempLabel.text = weatherdatamodel.temp
        
        print("\(weatherdatamodel.temperature)°")
        tempretureLabel.text = "\(String(weatherdatamodel.temperature))°"
        
        print(weatherdatamodel.weatherIconName)
        conditionImageView.image = UIImage(named: weatherdatamodel.weatherIconName)
        
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year =  components.year
        let month = components.month
        let day = components.day
        print("\(day!).\(month!).\(year!)")
        
        dateLabel.text = "\(day!).\(month!).\(year!)"
    }


}

