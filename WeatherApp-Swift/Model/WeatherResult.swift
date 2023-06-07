//
//  Weather.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation

struct WeatherResult: Codable {
    
    var location: Location?
    var current: Current?
}

struct Location: Codable {
    
    var name: String?
    var region: String?
    var country: String?
    var lat: Double?
    var lon: Double?
    var tz_id: String?
    var localtime_epoch: Int64?
    var localtime: String?
}

struct Current: Codable {
    
    var last_updated_epoch: Int64?
    var last_updated: String?
    var temp_c: Double?
    var temp_f: Double?
    var is_day: Int64?
    var condition: Condition?
    var wind_mph: Double?
    var wind_kph: Double?
    var wind_degree: Int64?
    var wind_dir: String?
    var pressure_mb: Double?
    var pressure_in: Double?
    var precip_mm: Double?
    var precip_in: Double?
    var humidity: Int64?
    var cloud: Int64?
    var feelslike_c: Double?
    var feelslike_f: Double?
    var vis_km: Double?
    var vis_miles: Double?
    var uv: Double?
    var gust_mph: Double?
    var gust_kph: Double?
}

struct Condition: Codable {
    
    var text: String?
    var icon: String?
    var code: Int64?
}
