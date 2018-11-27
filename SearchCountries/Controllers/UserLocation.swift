//
//  UserLocation.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import CoreLocation

final class UserLocation: NSObject, CLLocationManagerDelegate {
    
    //MARK: - properties
    private var locationManager = CLLocationManager()
    static let sharedInstance = UserLocation()
    
    var locationStatus : NSString = "Not Started"
    var location: CLLocation?
    
    var locationEnabled: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var errorMessage: String? {
        didSet {
            self.showErrorMessage?()
        }
    }
    
    var showErrorMessage: (()->())?
    var updateLoadingStatus: (()->())?
    
    //MARK: - Start
    
    func startLocating () {
        self.locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: - End
    
    func endLocating () {
        self.locationManager.stopUpdatingLocation()
        
    }
    
    //MARK: - Initializer
    
    private override init () {
        super.init()
        self.startLocating()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = manager.location!
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldAllow: Bool = false
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldAllow = true
        }
        
        if (shouldAllow == true) {
            // Start location services
            locationEnabled = true
            locationManager.startUpdatingLocation()
        } else {
            locationEnabled = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                errorMessage = "Location Unknown"
            case CLError.denied:
               errorMessage = "denied"
            default:
                errorMessage = "other Core Location error"
            }
        } else {
            errorMessage = "other error: \(error.localizedDescription)"
        }
    }
}


