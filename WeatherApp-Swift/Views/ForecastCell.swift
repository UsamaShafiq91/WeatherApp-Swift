//
//  ForecastCell.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 07/06/2023.
//

import Foundation
import UIKit

class ForecastCell: UICollectionViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = .clear
        
        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
    }
    
    func setData(forecastday: Forecastday) {
        let detailAttributed = NSMutableAttributedString()
        detailAttributed.append(NSAttributedString(string: "\(getValidValue(value: Date().dateFormat(date: forecastday.date, dateformat: "yyyy-MM-dd", desiredFormat: "d MMM")))\n", attributes: [.font: UIFont.mediumFont, .foregroundColor: UIColor.descriptionColor]))
        detailAttributed.append(NSAttributedString(string: "\(getValidValue(value: forecastday.day?.maxtemp_c)) / \(getValidValue(value: forecastday.day?.mintemp_c)) C\n", attributes: [.font: UIFont.normalFont, .foregroundColor: UIColor.descriptionColor]))
        detailAttributed.append(NSAttributedString(string: "\(getValidValue(value: forecastday.day?.condition?.text))", attributes: [.font: UIFont.normalFont, .foregroundColor: UIColor.descriptionColor]))
        
        detailLabel.attributedText = detailAttributed

        
        guard let imageUrl = URL(string: "https:\(forecastday.day?.condition?.icon ?? "")") else {
            return
        }
        
        iconImageView.kf.setImage(with: imageUrl)
    }
    
    func getValidValue(value: Any?) -> String {
        var validValue = "-"
        
        if let int64Value = value as? Int64 {
            validValue = "\(int64Value)"
        }
        else if let intValue = value as? Int {
            validValue = "\(intValue)"
        }
        else if let doubleValue = value as? Double {
            validValue = "\(doubleValue)"
        }
        else if let stringValue = value as? String, !stringValue.isEmpty {
            validValue = stringValue
        }
        
        return validValue
    }
}
