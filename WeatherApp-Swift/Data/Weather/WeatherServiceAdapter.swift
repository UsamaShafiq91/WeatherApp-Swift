//
//  WeatherServiceAdapter.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation

struct WeatherServiceAdapter: WeatherService {
    
    let api: AlamofireApi
    
    init() {
        api = AlamofireApi()
    }
    
    func getWeatherDetail(latitude: Double, longitude: Double, completion: @escaping (Response<WeatherResult>) -> Void) {
        api.doRequest(router: Router(endpoint: .getWeatherDetail(latitude: latitude, longitude: longitude)), completion: completion)
    }
    
    func getWeatherForecast(latitude: Double, longitude: Double, days: Int64, completion: @escaping(Response<ForecastResult>) -> Void) {
        api.doRequest(router: Router(endpoint: .getWeatherForecast(latitude: latitude, longitude: longitude, days: days)), completion: completion)
    }
    
    func getSearchResult(search: String, completion: @escaping(Response<[Location]>) -> Void) {
        api.doRequest(router: Router(endpoint: .getSearchResult(search: search)), completion: completion)
    }

}
