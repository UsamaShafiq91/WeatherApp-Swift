//
//  AlamofireApi.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation
import UIKit
import Alamofire

protocol WebApiProtocol {
    func doRequest<T: Codable>(router: BaseRouter, completion: @escaping (Response<T>) -> Void)
}

class AlamofireApi: WebApiProtocol {
    
    private let session: Session = Session();
    
    func doRequest<T: Codable>(router: BaseRouter, completion: @escaping (Response<T>) -> Void) {
        self.session.request(router).responseJSON {
            (response: AFDataResponse<Any>) in
            
            let data: T?, err: Error?
                                
            switch response.result {
            case .success(let result):
                (data, err) = self.handleSuccessResponse(result, statusCode: response.response?.statusCode)
                
                break
                
            case .failure(let error):
                data = nil
                err = error
                
                break
            }
            
            completion(Response(data: data, error: err))
        }
    }
    
    func handleSuccessResponse<T: Codable>(_ response: Any, statusCode: Int?) -> (data: T?, error: Error?) {
        var err: Error?
        var data: T?
        
        let decoder = JSONDecoder()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            data = try decoder.decode(T.self, from: jsonData)
        } catch {
            err = error
        }
        
        
        return (data, err)
    }
    
}
