//
//  GetWeather.swift
//  Weather
//
//  Created by programming-xcode on 2/12/18.
//  Copyright © 2018 programming-xcode. All rights reserved.
//

import Foundation
import AVFoundation

class GetWeather {
    var synth = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    let openWeatherMapAPIKey = "fb2fe400ceb2a97d0f746dec26e85707"
    
    func getWeather(city: String) {
        let session = URLSession.shared
        
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")
        
        let dataTask = session.dataTask(with: weatherRequestURL!, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error:\n\(error)")
            } else {
                do {
                    let weather = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    self.utterance = AVSpeechUtterance(string: "Weather data for \(weather["name"]!): It is \((weather["weather"]![0]! as! [String: AnyObject])["main"]!) outside. The temperature is \(weather["main"]!["temp"]!! as! Double - 273.14) Celcius. The Humidity is \(weather["main"]!["humidity"]!!) percent. The pressure is \(weather["main"]!["pressure"]!!) hpa. ")
                    self.utterance.rate = 0.4
                    self.synth.speak(self.utterance)
                }
                catch let jsonError as NSError {
                    print("JSON error: \(jsonError.description)")
                }
            }
        })
        dataTask.resume()
    }
}
