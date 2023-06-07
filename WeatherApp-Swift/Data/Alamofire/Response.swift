//
//  Response.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 06/06/2023.
//

import Foundation

struct Response<T> {
    let data: T?
    let error: Error?

    init(data: T?, error: Error?) {
        self.data = data
        self.error = error
    }
}

extension Response {
    func isOk() -> Bool {
        if self.error == nil {
            return true
        } else {
            return false
        }
    }
    
    func getResult() -> T? {
    
        if self.isOk(), let data = self.data {
            return data
        } else {
            return nil
        }
    }
}
