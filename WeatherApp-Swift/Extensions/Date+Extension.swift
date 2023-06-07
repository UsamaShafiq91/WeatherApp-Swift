//
//  Date+Extension.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 07/06/2023.
//

import Foundation

extension Date {
    
//    func getFormattedDate(date: String, desiredFormat: String) -> String? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        dateFormatter.date(from: date)
//        let fromDate = dateFormatter.string(from: date)
//
//    }
    
    func dateFormat(date:String?, dateformat:String, desiredFormat:String) -> String {
        guard let date = date else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateformat
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        if let utcDate: Date = formatter.date(from: date) {
            let formatter2 = DateFormatter()
            formatter2.dateFormat = desiredFormat
            formatter2.locale = Locale(identifier: "en_US_POSIX")
        
            let dateString = formatter2.string(from: utcDate)
            return dateString
        }
        
        return ""
    }
}
