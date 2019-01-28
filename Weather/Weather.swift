//
//  Weather.swift
//  Weather
//
//  Created by Oliver Green on 01/11/2018.
//  Copyright © 2018 Oliver Green. All rights reserved.
//

import Foundation
import CoreLocation

struct Weather {
    
    lazy var baseURL: URL = {
        return URL(string: "https://api.darksky.net/forecast/64d4092f2c53c1fbaf54b438b735d1d2/")
    }()!
    
    
}
