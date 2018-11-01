//
//  SearchCountriesViewModel.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

final class SearchCountriesViewModel {
    let apiService: APIServiceProtocol
    let userLocation: UserLocation//UserLocation.sharedInstance
    
    private var countries: [Country] = [Country]()
    var countriesUnSortedArray: [Country] = [Country]()
    
    var cellviewmodels: [SearchCountriesCellViewModel] = [SearchCountriesCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    var alertMessage: String? {
        didSet {
            self.showAlertMessage?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var numberOfCells: Int {
        return self.cellviewmodels.count
    }
    
    var reloadTableViewClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var showAlertMessage: (()->())?
    
    var searchText: String?
    var searchType: String?
    
    init() {
        self.apiService = APIService()
        self.userLocation = UserLocation.sharedInstance
        setUpBinding()
    }
    
    // I use this init for tests.
    init(apiService: APIServiceProtocol, userLocation: UserLocation) {
        self.apiService = apiService
        self.userLocation = userLocation
    }
    
    func setUpBinding() {
        self.userLocation.updateLoadingStatus = { [weak self] () in
            let isEnabled = self?.userLocation.locationEnabled ?? false
            if isEnabled {
                // Only if location is enabled we can start fetching
                self?.fetchCountries(searchText: self?.searchText, searchType: self?.searchType)
            } else {
                self?.alertMessage = "Please Allow the location Service to open this screen. Go to settings"
            }
        }
    }
    
    func initFetch(searchText: String?, searchType: String?) {
        self.searchText = searchText
        self.searchType = searchType
        
        if self.userLocation.locationEnabled {
            // Only if location is enabled we can start fetching
            self.fetchCountries(searchText: searchText, searchType: searchType)
        }
    }
    
    func fetchCountries(searchText: String?, searchType: String?) {
        self.isLoading = true
        self.apiService.fetchCountries(searchText: searchText, searchType: searchType) { [weak self] (response, error) in
            
            self?.isLoading = false
            if let countries = response {
                self?.processCountries(countries: countries)
            } else {
                if let error = error {
                    self?.alertMessage = error.localizedDescription
                    self?.cellviewmodels.removeAll()
                }
            }
            //
            //                switch result {
            //                case .success(let countries):
            //                    self?.processCountries(countries: countries)
            //                case .failure(let error):
            //                    self?.alertMessage = error.localizedDescription
            //                    self?.cellviewmodels.removeAll()
            //                }
        }
    }
    
    func processCountries(countries: [Country]) {
        self.calculateDistanceForCountries(countries: countries)
        self.createCellViewModel()
    }
    
    func calculateDistanceForCountries(countries: [Country]) {
        for var country in countries {
            if !country.latitudeLongitude.isEmpty {
                //Create CLLocation for latitudeLongitude from country object
                let countryLocation = CLLocation(latitude: country.latitudeLongitude[0], longitude: country.latitudeLongitude[1])
                //Calculate distance from user location
                country.distance = (self.userLocation.location?.distance(from:countryLocation))!
                //country.distance = 1000000000.0
            } else {
                // the latlng from server is empty so we don't know the exact location, we set a distance to put them in the end
                country.distance = 1000000000.0
            }
            self.countriesUnSortedArray.append(country)
        }
        self.countries = self.countriesUnSortedArray.sorted(by: {$0.distance < $1.distance})
        self.countriesUnSortedArray.removeAll()
    }
    
    func createCellViewModel() {
        // create the cell view model with the sorted array
        var searchCountriesCellViewModels = [SearchCountriesCellViewModel]()
        
        for country in self.countries {
            searchCountriesCellViewModels.append(createCellViewModel(country: country))
        }
        self.cellviewmodels = searchCountriesCellViewModels
        
    }
    
    func createCellViewModel(country: Country) -> SearchCountriesCellViewModel {
        return SearchCountriesCellViewModel( countryName: country.name, countryFlag_url: country.flag_url!, countryPopulation: "Population \(String(country.population))", countryArea: "Area \(country.area?.description ?? "0") km2")
    }
}

