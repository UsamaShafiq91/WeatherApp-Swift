//
//  ForecastResult.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation

struct ForecastResult: Codable {
    
    var location: Location?
    var current: Current?
    var forecast: Forecast?
}


struct Forecast: Codable {
    
    var forecastday: [Forecastday]?
}

struct Forecastday: Codable {
    
    var date: String?
    var date_epoch: Int64?
    var day: Day?
}


struct Day: Codable {
    
    var maxtemp_c: Double?
    var maxtemp_f: Double?
    var mintemp_c: Double?
    var mintemp_f: Double?
    var avgtemp_c: Double?
    var avgtemp_f: Double?
    var maxwind_mph: Double?
    var maxwind_kph: Double?
    var totalprecip_mm: Double?
    var totalprecip_in: Double?
    var totalsnow_cm: Double?
    var avgvis_km: Double?
    var avgvis_miles: Double?
    var avghumidity: Double?
    var condition: Condition?
}
