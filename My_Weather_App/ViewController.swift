
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
    let WEATHER_URL1 = "http://api.openweathermap.org/data/2.5/forecast/daily"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let date = Date()
    let calendar = Calendar.current
    
    // Hookup UI
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changeCityTextField: UITextField!
    
    @IBOutlet weak var tempday1: UILabel!
    @IBOutlet weak var tempday2: UILabel!
    @IBOutlet weak var tempday3: UILabel!
    @IBOutlet weak var tempday4: UILabel!
    @IBOutlet weak var tempday5: UILabel!
    
    
    @IBOutlet weak var imageday1: UIImageView!
    @IBOutlet weak var imageday2: UIImageView!
    @IBOutlet weak var imageday3: UIImageView!
    @IBOutlet weak var imageday4: UIImageView!
    @IBOutlet weak var imageday5: UIImageView!
    
    
    
    //Declare instance variables
    let locationmanager = CLLocationManager()
    let weatherdatamodel = WeatherDataModel()
    let weatherforecastdatamodel = WeatherForecastDataModel()
    
    
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
            let params : [String : String] = ["lat": latitude , "lon": longtitude, "appid": APP_ID]
        
            getWeatherData(url: WEATHER_URL, parameters: params)
            getForecastWeatherData(url: WEATHER_URL1, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: - GetWeatherData From API
    // Type of Get Data From API is Location (Lan & Lon ) & APP ID
    
    func getWeatherData(url: String, parameters: [String : String] ){
        
        Alamofire.request(url, method: .get , parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success ! got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.ParsingWeatherData(json: weatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
    //    func getWeatherData(lat: String , long: String){
    //    let WEATHER_URL1 = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=db492be2c9ffb3c34e5d05c39e837bf1"
    //
    //        Alamofire.request(WEATHER_URL1).responseJSON { (response) in
    //            if response.result.isSuccess {
    //                print("SUCCESS! Got the weather data from API")
    //                //print(response)
    //
    //                let weatherJSON : JSON = JSON(response.result.value!)
    //                print(weatherJSON)
    //                self.ParsingWeatherData(json: weatherJSON)
    //
    //            } else {
    //                print("Error \(String(describing: response.result.error))")
    //                //self.cityLabel.text = "Connection Issues"
    //            }
    //        }
    //    }
    
    
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
    
    
    @IBAction func chnageCityButton(_ sender: Any) {
        if changeCityTextField != nil {
            let city = changeCityTextField.text
            let params: [String : String] = ["q": city! , "appid" : APP_ID]
            getCitytWeatherData(url: WEATHER_URL, parameters: params)
            getForecastWeatherData(url: WEATHER_URL1, parameters: params)
            
        } else {
            return
        }
    }
    
    //MARK: - Get Forecast Weather Data
    // Type of Get Data From API is City & APP ID
    func getCitytWeatherData(url: String, parameters: [String : String] ){
        
        Alamofire.request(url, method: .get , parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success ! got the City  weather data")
                let weatherCityJSON : JSON = JSON(response.result.value!)
                print(weatherCityJSON)
                self.ParsingWeatherData(json: weatherCityJSON)
                } else {
                    print("Error \(String(describing: response.result.error))")
                
            }
        }
    }
    
    
    

    func getForecastWeatherData(url: String, parameters: [String : String] ){
        
        Alamofire.request(url, method: .get , parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success ! got the  Forcast weather data")
                
                let ForecastweatherJSON : JSON = JSON(response.result.value!)
                print(ForecastweatherJSON)
                self.ParsingForecastWeatherData(json: ForecastweatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
    func ParsingForecastWeatherData(json: JSON) {
        
        let result1 = json["list"][0]["temp"]["day"].intValue
        weatherforecastdatamodel.temp1 = (result1 - Int(273.15))
        let result2 = json["list"][1]["temp"]["day"].intValue
        weatherforecastdatamodel.temp2 = (result2 - Int(273.15))
        let result3 = json["list"][2]["temp"]["day"].intValue
        weatherforecastdatamodel.temp3 = (result3 - Int(273.15))
        let result4 = json["list"][3]["temp"]["day"].intValue
        weatherforecastdatamodel.temp4 = (result4 - Int(273.15))
        let result5 = json["list"][4]["temp"]["day"].intValue
        weatherforecastdatamodel.temp5 = (result5 - Int(273.15))
        
        
        weatherdatamodel.condition1 = json["list"][0]["weather"][0]["id"].intValue
        print(weatherdatamodel.condition1)
        weatherdatamodel.weatherIconName1 = weatherdatamodel.updateWeatherIcon(condition: weatherdatamodel.condition1)
        
        
        weatherdatamodel.condition2 = json["list"][1]["weather"][0]["id"].intValue
        weatherdatamodel.weatherIconName2 = weatherdatamodel.updateWeatherIcon(condition: weatherdatamodel.condition2)
        print(weatherdatamodel.condition2)
        
        weatherdatamodel.condition3 = json["list"][1]["weather"][0]["id"].intValue
        weatherdatamodel.weatherIconName3 = weatherdatamodel.updateWeatherIcon(condition: weatherdatamodel.condition3)
        print(weatherdatamodel.condition3)
        
        weatherdatamodel.condition4 = json["list"][1]["weather"][0]["id"].intValue
        weatherdatamodel.weatherIconName4 = weatherdatamodel.updateWeatherIcon(condition: weatherdatamodel.condition4)
        print(weatherdatamodel.condition4)
        
        weatherdatamodel.condition5 = json["list"][1]["weather"][0]["id"].intValue
        weatherdatamodel.weatherIconName5 = weatherdatamodel.updateWeatherIcon(condition: weatherdatamodel.condition5)
        print(weatherdatamodel.condition5)
        
        updateForecastUIWeatherDataModel()
        
    }
    
    func updateForecastUIWeatherDataModel() {
        
        tempday1.text = "\(weatherforecastdatamodel.temp1)"
        tempday2.text = "\(weatherforecastdatamodel.temp2)"
        tempday3.text = "\(weatherforecastdatamodel.temp3)"
        tempday4.text = "\(weatherforecastdatamodel.temp4)"
        tempday5.text = "\(weatherforecastdatamodel.temp5)"
        
        imageday1.image = UIImage(named: weatherdatamodel.weatherIconName1)
        imageday2.image = UIImage(named: weatherdatamodel.weatherIconName2)
        imageday3.image = UIImage(named: weatherdatamodel.weatherIconName3)
        imageday4.image = UIImage(named: weatherdatamodel.weatherIconName4)
        imageday5.image = UIImage(named: weatherdatamodel.weatherIconName5)
    
    }
    
    
    
}

