//
//  Router.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation
import Alamofire

enum EndPoint {
    case getWeatherDetail(latitude: Double, longitude: Double)
    case getWeatherForecast(latitude: Double, longitude: Double, days: Int64)
}

struct Router: BaseRouter {
    
    let endpoint: EndPoint
    var token: String?
    var baseUrl: String {
        switch endpoint {
        case .getWeatherDetail(_, _): return Constants.weatherBaseUrl
        case .getWeatherForecast(_, _, _): return Constants.weatherBaseUrl
        }
    }
    
    init(endpoint: EndPoint) {
        self.endpoint = endpoint
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }
    
    var path: String {
        switch endpoint {
        case .getWeatherDetail(_, _): return "/current.json"
        case .getWeatherForecast(_, _, _): return "/forecast.json"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch endpoint {
        case .getWeatherDetail(let latitude, let longitude):
            
            return [
                "q": "\(latitude),\(longitude)",
                "aqi": "no",
                "key": Constants.weatherApiKey,
            ] as [String: AnyObject]
            
        case .getWeatherForecast(let latitude, let longitude, let days):
            
            return [
                "q": "\(latitude),\(longitude)",
                "aqi": "no",
                "days": days,
                "key": Constants.weatherApiKey,
            ] as [String: AnyObject]
        
            
        default:
            return nil
        }
    }
    
    var file: Data? {
        return nil
    }
}
