
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

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    

    //Constants
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let WEATHER_URL_FORECAST = "https://api.openweathermap.org/data/2.5/forecast/daily"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let date = Date()
    let calendar = Calendar.current
    
    var tempArray = [String]()
    var tempratureArray = [Int]()
    var imageArray = [Int]()
    var iconArray = [String]()
    var dtArray = [Double]()
    var dateArray = [String]()
    var SomeInt = 0...6
    
    let format = DateFormatter()
    
    // Hookup UI
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changeCityTextField: UITextField!
    @IBOutlet weak var myTableView: UITableView!
    
    //Declare instance variables
    let locationmanager = CLLocationManager()
    let weatherdatamodel = WeatherDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
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
            getForecastWeatherData(url_1: WEATHER_URL_FORECAST, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: - GetWeatherData From API , Type of Get Data From API is Location (Lan & Lon ) & APP ID
    
    func getWeatherData(url: String, parameters: [String : String] ){
        Alamofire.request(url, method: .get , parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success ! got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                //print(weatherJSON)
                self.ParsingCurrentWeatherData(json: weatherJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    //MARK: - Parsing Current Weather Data JSON Formant
    func ParsingCurrentWeatherData(json: JSON) {
        
        weatherdatamodel.city = json["name"].stringValue
        weatherdatamodel.temp = json["weather"][0]["main"].stringValue
        let result = json["main"]["temp"].doubleValue
        weatherdatamodel.temperature = Int(result - 273.15)
        weatherdatamodel.condition = 0
        weatherdatamodel.condition = json["weather"][0]["id"].intValue
        weatherdatamodel.weatherIconName = weatherdatamodel.updateWeatherIcon(condition: weatherdatamodel.condition)
        updateUICurrentWeatherData()
        
    }
    
    //MARK: - Update UI WeatherData
    func updateUICurrentWeatherData(){
        
        cityLabel.text = weatherdatamodel.city
        tempLabel.text = weatherdatamodel.temp
        tempretureLabel.text = "\(String(weatherdatamodel.temperature))°"
        conditionImageView.image = UIImage(named: weatherdatamodel.weatherIconName)
        format.dateFormat = "EEEE, d MMM yyyy "
        let today = format.string(from: date)
        dateLabel.text = "\(today)"
        
        print(weatherdatamodel.city)
        print(weatherdatamodel.temp)
        print("\(weatherdatamodel.temperature)°")
        print(weatherdatamodel.weatherIconName)
    }
    
    //MARK: - Chnage City Name
    @IBAction func chnageCityButton(_ sender: Any) {
//        if changeCityTextField != nil {
//            let city = changeCityTextField.text
//            let params: [String : String] = ["q": city! , "appid" : APP_ID]
//
//            getCitytWeatherData(url: WEATHER_URL, parameters: params)
//            getForecastWeatherData(url_1: WEATHER_URL_FORECAST, parameters: params)
//
//        } else {
//            return
//        }
//
//        changeCityTextField.text = ""
        
        guard let city = changeCityTextField.text , !city.isEmpty else { return }
        let params: [String : String] = ["q": city , "appid" : APP_ID]
        getCitytWeatherData(url: WEATHER_URL, parameters: params)
        getForecastWeatherData(url_1: WEATHER_URL_FORECAST, parameters: params)
        changeCityTextField.text = ""
    }
    
    //MARK: - Get Forecast Weather Data
    // Type of Get Data From API is City & APP ID
    func getCitytWeatherData(url: String, parameters: [String : String] ){
        
        Alamofire.request(url, method: .get , parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success ! got the City  weather data")
                let weatherCityJSON : JSON = JSON(response.result.value!)
                print(weatherCityJSON)
                self.ParsingCurrentWeatherData(json: weatherCityJSON)
                } else {
                    print("Error \(String(describing: response.result.error))")
            }
        }
    }
    


    func getForecastWeatherData(url_1: String, parameters: [String : String] ){
        
        Alamofire.request(url_1, method: .get , parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success ! got the  Forcast weather data")
                
                let ForecastweatherJSON : JSON = JSON(response.result.value!)
                print(ForecastweatherJSON)
                
                self.tempArray.removeAll()
                self.dateArray.removeAll()
                self.dtArray.removeAll()
                self.tempratureArray.removeAll()
                self.imageArray.removeAll()
                self.iconArray.removeAll()
                //-------- Type of Sutation ( Clear , Rain , Snow )
                for m in self.SomeInt {
                    let temp = ForecastweatherJSON["list"][m]["weather"][0]["main"].stringValue
                    self.tempArray.append(temp)
                }
                
                //----- date of forecast  "dt"
                for m in self.SomeInt {
                    let timeResult = ForecastweatherJSON["list"][m]["dt"].doubleValue
                    
                    // Convert Unix Timestamp
                    let date = Date(timeIntervalSince1970: timeResult)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE" //Set time style
                    let localDate = dateFormatter.string(from: date)
                    self.dtArray.append(timeResult)
                    self.dateArray.append(localDate)
                 /*
                    print(date)         //show 2019-06-02 20:00:00 +0000
                    print(timeResult)   //show dt:155924...
                    print(localDate)    //show day of weeks
                     */
                }
                
                for m in self.SomeInt {
                    let temprature = ForecastweatherJSON["list"][m]["temp"]["day"].doubleValue
                    let temprature1 = Int(temprature - 273.15)
                    self.tempratureArray.append(temprature1)
                }
                
                for m in self.SomeInt {
                    let image = ForecastweatherJSON["list"][m]["weather"][0]["id"].intValue
                    self.imageArray.append(image)
                    self.weatherdatamodel.weatherIconName = self.weatherdatamodel.updateWeatherIcon(condition: image)
                    self.iconArray.append(self.weatherdatamodel.weatherIconName)
                }
                
                
                    print(self.tempArray)
                    //print(self.dtArray)
                    print(self.dateArray)
                    print(self.tempratureArray)
                    print(self.imageArray)
                    print(self.iconArray)
                
                self.ParsingForecastWeatherData(json: ForecastweatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
    func ParsingForecastWeatherData(json: JSON) {
        updateForecastUIWeatherDataModel()
    }
    
    func updateForecastUIWeatherDataModel() {
        self.myTableView.reloadData()
    }
    
    //MARK: - TableView For Showing Forecast Information
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if tempArray != [String]() {
            cell.tempSituationTableViewCell.text = "\(tempArray[indexPath.row])"
            cell.dayTableViewCell.text = "\(dateArray[indexPath.row])"
            cell.tempratureTableViewCell.text = "\(tempratureArray[indexPath.row])°"
            cell.imageTableViewCell.image = UIImage(named: iconArray[indexPath.row])
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

