//
//  WeatherService.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation

protocol WeatherService {
    func getWeatherDetail(latitude: Double, longitude: Double, completion: @escaping(Response<WeatherResult>) -> Void)
    
    func getWeatherForecast(latitude: Double, longitude: Double, days: Int64, completion: @escaping(Response<ForecastResult>) -> Void)
}
