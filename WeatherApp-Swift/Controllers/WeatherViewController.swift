//
//  ViewController.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 26/05/2023.
//

import UIKit
import CoreLocation
import Kingfisher

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var cityImageView: UIImageView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherDetailLabel: UILabel!
    
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    var city: String?
    var weatherService: WeatherService?
    var weatherResult: WeatherResult?
    var forecastResult: ForecastResult?
    var forecastdays: [Forecastday] = []

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupLocationManager()
        setupView()
        setupAdapter()
    }

    func setupView() {
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        guard let city = city else { return }
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.title = city
    }
    
    func setupAdapter() {
        weatherService = WeatherServiceAdapter()
    }
    
    func getWeatherDetail() {
        guard checkLocationPermissions() else {
            showLocationAlert()
            return
        }
        
        guard let latitude = currentLocation?.coordinate.latitude, let longitude = currentLocation?.coordinate.longitude else { return }
        
        weatherService?.getWeatherDetail(latitude: latitude, longitude: longitude, completion: { [weak self] response in
            
            guard let data = response.data else { return }
            
            self?.weatherResult = data
            
            self?.setupWeatherData()
        })
    }
    
    func setupWeatherData() {
        cityNameLabel.text = weatherResult?.location?.name
        cityNameLabel.font = .titleFont
        cityNameLabel.textColor = .titleColor
        
        if let current = weatherResult?.current {
            let weatherDetailAttributed = NSMutableAttributedString()
            
            weatherDetailAttributed.append(NSAttributedString(string: "\(current.condition?.text ?? "")\n", attributes: [.font: UIFont.titleFont, .foregroundColor: UIColor.titleColor]))
            
            weatherDetailAttributed.append(NSAttributedString(string: "\(String.feelsLike) ", attributes: [.font: UIFont.keywordFont, .foregroundColor: UIColor.descriptionColor]))
            weatherDetailAttributed.append(NSAttributedString(string: "\(getValidValue(value: current.feelslike_c)) C\n", attributes: [.font: UIFont.normalFont, .foregroundColor: UIColor.descriptionColor]))
            
            weatherDetailAttributed.append(NSAttributedString(string: "\(String.windSpeed): ", attributes: [.font: UIFont.keywordFont, .foregroundColor: UIColor.descriptionColor]))
            weatherDetailAttributed.append(NSAttributedString(string: "\(getValidValue(value: current.wind_kph)) \(String.kph)\n", attributes: [.font: UIFont.normalFont, .foregroundColor: UIColor.descriptionColor]))
            
            weatherDetailAttributed.append(NSAttributedString(string: "\(String.pressure): ", attributes: [.font: UIFont.keywordFont, .foregroundColor: UIColor.descriptionColor]))
            weatherDetailAttributed.append(NSAttributedString(string: "\(getValidValue(value: current.pressure_mb)) \(String.millibars)\n", attributes: [.font: UIFont.normalFont, .foregroundColor: UIColor.descriptionColor]))
            
            weatherDetailAttributed.append(NSAttributedString(string: "\(String.humidity): ", attributes: [.font: UIFont.keywordFont, .foregroundColor: UIColor.descriptionColor]))
            weatherDetailAttributed.append(NSAttributedString(string: "\(getValidValue(value: current.humidity)) %", attributes: [.font: UIFont.normalFont, .foregroundColor: UIColor.descriptionColor]))

            
            weatherDetailLabel.attributedText = weatherDetailAttributed
            
            if let imageUrl = URL(string: "https:\(current.condition?.icon ?? "")") {
                weatherIconImageView.kf.setImage(with: imageUrl)
            }
        }
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
    
    func getWeatherForecast() {
        guard checkLocationPermissions() else { return }
        
        guard let latitude = currentLocation?.coordinate.latitude, let longitude = currentLocation?.coordinate.longitude else { return }
        
        weatherService?.getWeatherForecast(latitude: latitude, longitude: longitude, days: 7, completion: { [weak self] response in
            
            guard let data = response.data else { return }
            
            self?.forecastResult = data
            
            self?.setupCollectionView()
        })
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        guard checkLocationPermissions() else { return }
        
        locationManager.startUpdatingLocation()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            
            getWeatherDetail()
            getWeatherForecast()
        }
    }
    
    func showLocationAlert() {
        let alertController = UIAlertController(title: .locationPermissionRequired, message: .locationPermissionMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: .settings, style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: .cancel, style: .default, handler: {(cAlertAction) in
        })
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    func checkLocationPermissions() -> Bool {
        var isAllowed = false
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            isAllowed = true
        }
        else {
            isAllowed = false
        }
       
        return isAllowed
    }
}

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func setupCollectionView() {
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        forecastCollectionView.backgroundColor = .clear

        forecastCollectionView.register(UINib(nibName: ForecastCell.NibName, bundle: nil), forCellWithReuseIdentifier: ForecastCell.reuseIdentifier)
        
        forecastdays.removeAll()
        
        if let forecastday = forecastResult?.forecast?.forecastday {
            self.forecastdays = forecastday
        }
        
        if forecastResult?.current?.is_day == 1 {
            forecastCollectionView.backgroundColor = .dayColor.withAlphaComponent(0.7)
        }
        else {
            forecastCollectionView.backgroundColor = .nightColor.withAlphaComponent(0.7)
        }
        
        forecastCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastdays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let forecastCell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCell.reuseIdentifier, for: indexPath) as? ForecastCell else {
            return UICollectionViewCell()
        }
        
        forecastCell.setData(forecastday: forecastdays[indexPath.row])
        
        return forecastCell
    }
}
