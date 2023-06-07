//
//  String+Localize.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation
extension String {
    
    static let locationPermissionRequired = NSLocalizedString("Location Permission Required", comment: "")
    static let locationPermissionMessage = NSLocalizedString("Please enable location permissions to get accurate weather data.", comment: "")
    
    static let settings = NSLocalizedString("Settings", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    
    static let feelsLike = NSLocalizedString("Feels like", comment: "")
    static let windSpeed = NSLocalizedString("Wind Speed", comment: "")
    static let kph = NSLocalizedString("kph", comment: "")
    static let pressure = NSLocalizedString("Pressure", comment: "")
    static let millibars = NSLocalizedString("millibars", comment: "")
    static let humidity = NSLocalizedString("Humidity", comment: "")
    
    static let searchCity = NSLocalizedString("Search City", comment: "")
}
