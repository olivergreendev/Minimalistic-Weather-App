//
//  ViewController.swift
//  Weather
//
//  Created by Oliver Green on 01/11/2018.
//  Copyright © 2018 Oliver Green. All rights reserved.
//

import UIKit
import CoreLocation

extension UIScrollView {
    
    func roundCorners(cornerRadius: Double) {
        
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
    }
}

extension UIView {
    
    func roundCorner(cornerRadius: Double) {
        
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
    }
}

extension UIButton {
    
    func rotate360Degrees(duration: CFTimeInterval = 1, repeatCount: Float) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = repeatCount
        
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var weatherView: UIScrollView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var stateName: UILabel!
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var currentStatus: UILabel!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var weatherImageLarge: UIImageView!
    
    let baseURL = "http://api.openweathermap.org/data/2.5/weather"
    let apiKey = "5c7324600085619e5ab51952cb5ceee0"
    
    var currentCondition = ""
    var hourlyTemp = "??°"
    var currentCity = ""
    
    //var dayTemp: UILabel! = nil
    
    var tempArray: [String] = ["0", "1", "2", "3", "4"]
    
    var hourlyTempLabels: [UILabel] = []
    var hourlyWeatherImages: [UIImageView] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        weatherView.roundCorners(cornerRadius: 20.0)
        dataView.roundCorner(cornerRadius: 20.0)
        
        cityName.text = "city_name"
        stateName.text = "city_state"
        currentDate.text = "current_date"
        currentTemp.text = "??°C"
        
        adjustInitialPositions(shift: 0)
        initScrollView(state: false)
        
        searchBar.layer.cornerRadius = 20
        searchBar.backgroundColor = UIColor(red: 76/255.0, green: 46/255.0, blue: 137/255.0, alpha: 1.0)
        searchBar.frame.size.height = 40
        
        if getTime() >= 17 || getTime() <= 7 {
            setLargeWeatherImage(condition: "Clear", time: "Night")
        } else {
            setLargeWeatherImage(condition: "Clear", time: "Day")
        }
        
    }
    
    func getWeatherData(city: String) {
        
        let session = URLSession.shared
        let formatCity = (city as NSString).replacingOccurrences(of: " ", with: "+")
        let requestURL = URL(string: "\(baseURL)?APPID=\(apiKey)&q=\(formatCity)")
        let dataTask = session.dataTask(with: requestURL!, completionHandler: { (data, response, error) in
            
            if let error = error {
                print(error)
            } else {
                
                do {
                    
                    let weather = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    
                    self.currentStatus.text = String("\((weather["weather"]![0]! as! [String: AnyObject])["main"]!)")
                    self.currentTemp.text = String("\(Int(weather["main"]!["temp"]!! as! Double - 273.14))°C")
                    self.hourlyTemp = String("\(Int(weather["main"]!["temp"]!! as! Double - 273.14))°")
                    
                    var currentCondition = String(describing: (weather["weather"]![0]! as! [String: AnyObject])["main"]!)
                    
                    if (self.getTime() >= 17) {
                        self.setLargeWeatherImage(condition: currentCondition, time: "Night")
                    } else {
                        self.setLargeWeatherImage(condition: currentCondition, time: "Day")
                    }
                    
                    for i in 0...4 {
                        self.tempArray[i] = self.hourlyTemp
                    }
                
                    // this sets the last dayTemp label correctly because its actually the only UILabel that's initiated in initScrollView
                    //dayTemp.text = self.hourlyTemp
                    for i in 0...4 {
                        self.hourlyTempLabels[i].text = self.hourlyTemp
                        self.hourlyWeatherImages[i].image = #imageLiteral(resourceName: "cloudy-small")
                    }
                }
                    
                catch let jsonError as NSError {
                    print("JSON error: \(jsonError.description)")
                }
            }
        })
        
        dataTask.resume()
    }
    
    func getTime() -> Int {
        
        var date = Date()
        var calendar = Calendar.current
        var currentHour = calendar.component(.hour, from: date)
        
        return currentHour
    }
    
    func setLargeWeatherImage(condition: String, time: String) {
        
        var xPos = self.view.frame.width / 2
        var yPos = self.view.frame.height / 2
        
        switch (condition) {
            
        case "Thunderstorm":
            self.weatherImageLarge.frame = CGRect(x: xPos - 70, y: yPos - 65, width: 140, height: 135)
            if (time == "Day") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "thunder-day-large")
            } else if (time == "Night") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "thunder-night-large")
            }
            break
        case "Drizzle":
            self.weatherImageLarge.frame = CGRect(x: xPos - 55, y: yPos - 70, width: 125, height: 140)
            if (time == "Day") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "rain-day-large")
            } else if (time == "Night") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "rain-night-large")
            }
            break
        case "Rain":
            self.weatherImageLarge.frame = CGRect(x: xPos - 55, y: yPos - 70, width: 125, height: 140)
            if (time == "Day") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "rain-day-large")
            } else if (time == "Night") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "rain-night-large")
            }
            break
        case "Snow":
            self.weatherImageLarge.frame = CGRect(x: xPos - 70, y: yPos - 45, width: 140, height: 89)
            self.weatherImageLarge.image = #imageLiteral(resourceName: "cloudy-large")
            break
        case "Mist":
            self.weatherImageLarge.frame = CGRect(x: xPos - 70, y: yPos - 45, width: 140, height: 89)
            self.weatherImageLarge.image = #imageLiteral(resourceName: "cloudy-large")
            break
        case "Clear":
            self.weatherImageLarge.frame = CGRect(x: xPos - 70, y: yPos - 70, width: 140, height: 140)
            if (time == "Day") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "clear-day-large")
            } else if (time == "Night") {
                self.weatherImageLarge.image = #imageLiteral(resourceName: "clear-night-large")
            }
            break
        case "Clouds":
            self.weatherImageLarge.frame = CGRect(x: xPos - 70, y: yPos - 45, width: 140, height: 89)
            self.weatherImageLarge.image = #imageLiteral(resourceName: "cloudy-large")
            break
        case "Fog":
            self.weatherImageLarge.frame = CGRect(x: xPos - 70, y: yPos - 45, width: 140, height: 89)
            self.weatherImageLarge.image = #imageLiteral(resourceName: "cloudy-large")
            break
        default:
            print("not catering for a certain weather condition; cannot assign an image to \(condition)")
            break
        }
    }
    
    func adjustInitialPositions(shift: CGFloat) {
        
        cityName.center.y += shift
        cityName.alpha = 0.0
        stateName.center.y += shift
        stateName.alpha = 0.0
        currentTemp.center.y += shift
        currentTemp.alpha = 0.0
        dataView.center.y += shift
        dataView.alpha = 0.0
        currentStatus.center.y += shift
        currentStatus.alpha = 0.0
        weatherImageLarge.center.y += shift
        weatherImageLarge.alpha = 0.0
    }
    
    func animateObjectsIn(city: String, state: String) {
        
        cityName.text = city
        stateName.text = state
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
                
                self.cityName.center.y -= 30
                self.cityName.alpha = 1.0
                
            }), completion: { (finished: Bool) in })
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                UIView.animate(withDuration: 1.0, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
                    
                    self.stateName.center.y -= 30
                    self.stateName.alpha = 1.0
                    
                }), completion: { (finished: Bool) in })
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    
                    UIView.animate(withDuration: 1.0, delay: 0.6, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
                        
                        self.currentTemp.center.y -= 30
                        self.currentTemp.alpha = 1.0
                        
                    }), completion: { (finished: Bool) in })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        
                        UIView.animate(withDuration: 1.0, delay: 0.6, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
                            
                            self.dataView.center.y -= 30
                            self.dataView.alpha = 1.0
                            self.currentStatus.center.y -= 30
                            self.currentStatus.alpha = 1.0
                            self.weatherImageLarge.center.y -= 30
                            self.weatherImageLarge.alpha = 1.0
                                                        
                        }), completion: { (finished: Bool) in })
                    }
                }
            }
        }
    }
    
    func initScrollView(state: Bool) {
        
        // addDayToScrollView(day: "M", weather: "sun-clear.png", temp: "18°", shift: 30)
        
        var date = Date()
        var calendar = Calendar.current
        var currentHour = calendar.component(.hour, from: date)
        
        var xPos = 40
        
        var counter = 0
        
        var timeArray = [0, 1, 2, 3, 4]
        var weatherArray: [String] = ["0", "1", "2", "3", "4"]
        
        
        if (!state) {
        
            for hourShift in 0...4 {
                
                var hourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                var weatherImage = UIImage(named: "clear-day-small")
                var weatherImageView = UIImageView(image: weatherImage!)
                var dayTemp = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
                
                hourlyTempLabels.append(dayTemp)
                hourlyWeatherImages.append(weatherImageView)
                
                hourLabel.center = CGPoint(x: CGFloat(xPos), y: CGFloat(25) - 20)
                hourLabel.textAlignment = .center
                
                var newTime = (currentHour + hourShift)
                
                if (newTime > 23) {
                    newTime = (0 + counter)
                    counter += 1
                }
                
                timeArray[hourShift] = newTime
                weatherArray[hourShift] = "clear-night-small"
                tempArray[hourShift] = hourlyTemp
                
                hourLabel.text = String(timeArray[hourShift])
                hourLabel.textColor = UIColor.white
                hourLabel.font = hourLabel.font.withSize(13)
                hourLabel.alpha = 0.0
                
                weatherImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                weatherImageView.center = CGPoint(x: CGFloat(xPos), y: CGFloat((weatherView.frame.height / 2)) - 20)
                weatherImageView.alpha = 0.0
                weatherImageView.image = UIImage(named: weatherArray[hourShift])
                
                dayTemp.center = CGPoint(x: CGFloat(xPos), y: CGFloat((weatherView.frame.height - 25)) - 20)
                dayTemp.textAlignment = .center
                dayTemp.text = tempArray[hourShift]
                dayTemp.textColor = UIColor.white
                dayTemp.font = dayTemp.font.withSize(15)
                dayTemp.alpha = 0.0
                
                xPos += 65
                
                weatherView.addSubview(hourLabel)
                weatherView.addSubview(weatherImageView)
                weatherView.addSubview(dayTemp)
                
                UIView.animate(withDuration: 1.0, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
                    
                    hourLabel.center.y += 20
                    hourLabel.alpha = 1.0
                    weatherImageView.center.y += 20
                    weatherImageView.alpha = 1.0
                    dayTemp.center.y += 20
                    dayTemp.alpha = 1.0
                    
                }), completion: { (finished: Bool) in })
            }
        } else {
            // update the hourly labels
            // update the hourly images
            // update the hourly temps
            
            // create an array of UILabels
            // reference each UILabel using a for loop
            
            for i in 0...4 {
                
            }
        }
    }

    @IBAction func tapRefresh(_ sender: UIButton) {
        
        refreshBtn.rotate360Degrees(repeatCount: 6)
        initScrollView(state: true)
        getWeatherData(city: currentCity)
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        var result = searchBar.text
        var formatCity = (result as! NSString).replacingOccurrences(of: " ", with: "+")
        var state: String = ""
        
        currentCity = formatCity
        
        if result != cityName.text && searchBar.hasText == true { // currently accepts any input that isn't equal to the current city label, this is when the users city choice needs to be cross referenced with a JSON data table view etc
            
            getWeatherData(city: formatCity)
            adjustInitialPositions(shift: 30)
            
            if (result == "San Francisco" || result == "Los Angeles") {
                animateObjectsIn(city: result!, state: "California")
            } else if (result == "London") {
                animateObjectsIn(city: result!, state: "United Kingdom")
            }
        }
        
        return true
    }
    
    func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        
        searchBar.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
}

/* // START_FUNC_addDayToScrollView
func addDayToScrollView(day: Int, weather: String, temp: String, shift: CGFloat) {
    
    let weekDay = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let condition = UIImage(named: weather)
    let weatherImageView = UIImageView(image: condition!)
    let dayTemp = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    switch weather {
        
    case "sun-clear.png":
        width = 30
        height = 30
    case "partly-cloudy.png":
        width = 35
        height = 29
    default:
        width = 30
        height = 30
    }
    
    weekDay.center = CGPoint(x: shift * 1.5, y: 10)
    weekDay.textAlignment = .center
    weekDay.text = String(day)
    weekDay.textColor = UIColor.white
    weekDay.font = weekDay.font.withSize(13)
    weekDay.alpha = 0.0
    
    weatherImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    weatherImageView.center = CGPoint(x: shift * 1.5, y: (weatherView.frame.height / 2) - 20)
    weatherImageView.alpha = 0.0
    
    dayTemp.center = CGPoint(x: shift * 1.5, y: 80)
    dayTemp.textAlignment = .center
    dayTemp.text = temp
    dayTemp.textColor = UIColor.white
    dayTemp.font = dayTemp.font.withSize(15)
    dayTemp.alpha = 0.0
    
    weatherView.addSubview(weekDay)
    weatherView.addSubview(weatherImageView)
    weatherView.addSubview(dayTemp)
    
    UIView.animate(withDuration: 1.0, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
        
        weekDay.center.y += 20
        weekDay.alpha = 1.0
        weatherImageView.center.y += 20
        weatherImageView.alpha = 1.0
        dayTemp.center.y += 20
        dayTemp.alpha = 1.0
        
    }), completion: { (finished: Bool) in })
}
*/ // END_FUNC_addDayToScrollView
