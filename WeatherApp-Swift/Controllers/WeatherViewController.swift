//
//  ViewController.swift
//  WeatherApp-Swift
//
//  Created by UsamaShafiq on 26/05/2023.
//

import UIKit
import CoreLocation
import Kingfisher
import SearchTextField
import NVActivityIndicatorView

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherDetailLabel: UILabel!
    
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var locationSearchTextField: SearchTextField!
    
    var city: String?
    var weatherService: WeatherService?
    var weatherResult: WeatherResult?
    var forecastResult: ForecastResult?
    var forecastdays: [Forecastday] = []
    var searchResult: [Location] = []

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var isSearchedLocation = false
    var searchedLocation: CLLocation?
    
    var loader: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupAdapter()
        setupLocationManager()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationSearchTextField.text = nil
        searchedLocation = nil
    }

    func setupView() {
        setupLoader()
        backButton.isHidden = true
        
        setupSearchField()
        
        guard isSearchedLocation else { return }
        
        backButton.isHidden = false
    }
    
    func setupLoader() {
        loader = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        loader?.center = self.view.center
        
        if let loader = loader {
            self.view.addSubview(loader)
        }
    }
    
    @IBAction func backButtonTapped() {
        self.dismiss(animated: true)
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
        
        loader?.startAnimating()
        
        weatherService?.getWeatherDetail(latitude: latitude, longitude: longitude, completion: { [weak self] response in
            
            self?.loader?.stopAnimating()
            
            guard let data = response.data else {
                self?.showErrorAlert(errorMessage: response.error.debugDescription)
                
                return
            }
            
            self?.weatherResult = data
            
            self?.setupWeatherData()
        })
    }
    
    func setupWeatherData() {
        if weatherResult?.current?.is_day == 1 {
            backgroundImageView.image = UIImage(named: "day")
        }
        else {
            backgroundImageView.image = UIImage(named: "night")
        }
        
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
        guard !isSearchedLocation else {
            getWeatherDetail()
            getWeatherForecast()

            return
        }
        
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .denied:
            showLocationAlert()
            break
        case .restricted:
            showLocationAlert()
            break
        default:
            break
        }
    }
    
    func showLocationAlert() {
        let alertController = UIAlertController(title: .locationPermissionRequired, message: .locationPermissionMessage, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: .settings, style: .default, handler: {(cAlertAction) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        alertController.addAction(settingsAction)
        
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
    
    func showErrorAlert(errorMessage: String) {
        let alertController = UIAlertController(title: .error, message: errorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: .ok, style: .default, handler: {(cAlertAction) in
        })
        alertController.addAction(okAction)
                
        self.present(alertController, animated: true)
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

extension WeatherViewController: UITextFieldDelegate {
    
    func setupSearchField() {
        locationSearchTextField.isHidden = true
        
        guard !isSearchedLocation else { return }
        
        locationSearchTextField.isHidden = false
        locationSearchTextField.delegate = self
        locationSearchTextField.placeholder = .searchCity
        locationSearchTextField.returnKeyType = .search
        locationSearchTextField.autocorrectionType = .no
        
        locationSearchTextField.startSuggestingImmediately = true
        locationSearchTextField.startVisible = true
        locationSearchTextField.theme.bgColor = UIColor.white
        
        locationSearchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        locationSearchTextField.itemSelectionHandler = {item, itemPosition in
            self.locationSearchTextField.text = item[itemPosition].title
            self.searchedLocation = nil
            
            if let latitude = self.searchResult[itemPosition].lat, let longitude = self.searchResult[itemPosition].lon {
                self.searchedLocation = CLLocation(latitude: latitude, longitude: longitude)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        getLocationSuggestions()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        goToCustomLocation()
        
        return true
    }
    
    func getLocationSuggestions() {
        guard let location = locationSearchTextField.text, !location.isEmpty else { return }
        
        searchedLocation = nil
        
        weatherService?.getSearchResult(search: location, completion: { [weak self] response in
            
            guard let data = response.data else { return }
            
            self?.searchResult = data
            
            let suggestions: [String] = data.map({ "\($0.name ?? ""), \($0.country ?? "")" })

            self?.locationSearchTextField.filterStrings(suggestions)
        })
    }
    
    func goToCustomLocation() {
        guard let searchedLocation = searchedLocation else { return }
        
        let weatherVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: MainStoryboard.Weather.rawValue) as? WeatherViewController ?? WeatherViewController()
        
        weatherVC.isSearchedLocation = true
        weatherVC.currentLocation = searchedLocation
        weatherVC.modalPresentationStyle = .fullScreen
        
        self.present(weatherVC, animated: true)
    }
}
