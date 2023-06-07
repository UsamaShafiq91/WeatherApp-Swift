//
//  BaseRouter.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation
import Alamofire

protocol BaseRouter: URLRequestConvertible {
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
    var path: String { get }
    var parameters: [String: AnyObject]? { get }
    var baseUrl: String { get }
}

// Default implementation
extension BaseRouter {
    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseUrl) else {
            throw NSError(domain: "Invalid url", code: 400, userInfo: nil)
        }

        urlComponents.path.append(path)
        
        var request = try URLRequest(url: urlComponents.asURL())
        request.httpMethod = method.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 300
        
        
        return try encoding.encode(request, with: parameters)
    }
}
