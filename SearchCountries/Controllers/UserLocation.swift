//
//  UserLocation.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import CoreLocation

final class UserLocation: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    static let sharedInstance = UserLocation()
    
    var locationStatus : NSString = "Not Started"
    
    var currentLocation2d: CLLocationCoordinate2D?
    var location: CLLocation?
    
    var locationEnabled: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    var updateLoadingStatus: (()->())?
    
    func startLocating () {
        self.locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func endLocating () {
        self.locationManager.stopUpdatingLocation()
        
    }
    
    //private override init () {
    override init () {
        super.init()
        self.startLocating()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = manager.location!
        self.currentLocation2d = manager.location?.coordinate
        
        //TODO: borrar esto que no lo necesito mas.
        let userLocationLatitude = self.currentLocation2d?.latitude
        let userLocationLongitud = self.currentLocation2d?.longitude
        if let userlatitud = userLocationLatitude {
            print("user latitud en UserLocation")
            print(userlatitud)
        }
        
        if let userLong = userLocationLongitud {
            print("user long en UserLocation")
            print(userLong)
        }
        
        self.endLocating()
        
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
            NSLog("Location to Allowed")
            // Start location services
            locationEnabled = true
            locationManager.startUpdatingLocation()
            
            
            
        } else {
            locationEnabled = false
            NSLog("Denied access: \(locationStatus)")
        }
        
    }
    
    //TODO: handle todos estos errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                print("location unknown")
            case CLError.denied:
                print("denied")
            default:
                print("other Core Location error")
            }
        } else {
            print("other error:", error.localizedDescription)
        }
    }
    
}


