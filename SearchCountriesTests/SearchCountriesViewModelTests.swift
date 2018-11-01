//
//  SearchCountriesViewModelTests.swift
//  SearchCountriesTests
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import XCTest
import CoreLocation
@testable import SearchCountries

class SearchCountriesViewModelTests: XCTestCase {
    var sut: SearchCountriesViewModel!
    var mockAPIService: MockApiService!
    
    enum APIError: String, Error {
        case noNetwork = "No Network"
        case serverOverload = "Server is overloaded"
        case permissionDenied = "You don't have permission"
    }
    
    
    override func setUp() {
        mockAPIService = MockApiService()
        mockAPIService.session = MockURLSession()
        
        let userLocation = UserLocation.sharedInstance
        userLocation.location = CLLocation(latitude: 40.0, longitude: 20.0)
        
        sut = SearchCountriesViewModel(apiService: mockAPIService, userLocation: userLocation)
        sut.userLocation.locationEnabled = true
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func testFetchCountry() {
        // Given
        mockAPIService.completeCountries = [Country]()
        
        // When
        sut.initFetch(searchText: nil, searchType: nil)
        
        // Assert
        XCTAssert(mockAPIService!.isFetchCountriesCalled)
    }
    
    func testFetchCountryFailed() {
        
        // Given a failed fetch with a certain failure
        let error = APIError.permissionDenied
        
        // When
        sut.initFetch(searchText: nil, searchType: nil)
        
        mockAPIService.fetchFail(error: error )
        
        // Sut should display predefined error message
        XCTAssertEqual( sut.alertMessage, error.localizedDescription )
    }
    
    func testCreateCellViewModel() {
        // Given
        let countries = StubGenerator().stubCountries()
        mockAPIService.completeCountries = countries
        let expect = XCTestExpectation(description: "reload closure triggered")
        sut.reloadTableViewClosure = { () in
            expect.fulfill()
        }
        
        // When
        sut.initFetch(searchText: nil, searchType: nil)
        mockAPIService.fetchSuccess()
        
        // Number of cell view model is equal to the number of countries
        XCTAssertEqual(sut.numberOfCells, countries.count)
        
        // XCTAssert reload closure triggered
        wait(for: [expect], timeout: 1.0)
    }
    
    func testLoadingWhenFetching() {
        
        //Given
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }
        
        //when fetching
        sut.initFetch(searchText: nil, searchType: nil)
        
        // Assert
        XCTAssertTrue( loadingStatus )
        
        // When finished fetching
        mockAPIService!.fetchSuccess()
        XCTAssertFalse( loadingStatus )
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func testSearchCountriesCellViewModelWasCreatedProperly() {
        //Given country
        let country = StubGenerator().stubCountries().first
        if let country = country {
            // When create cell view model
            let cellViewModel = sut!.createCellViewModel(country: country)
            
            // Assert the correctness of display information
            XCTAssertEqual( country.name, cellViewModel.countryName )
            XCTAssertEqual( country.flag_url, cellViewModel.countryFlag_url)
            XCTAssertEqual( "Population \(String(country.population))", cellViewModel.countryPopulation)
            XCTAssertEqual( "Area \(country.area?.description ?? "0") km2", cellViewModel.countryArea)
        }
    }
}

class MockApiService: APIServiceProtocol {
    var session = MockURLSession()
    var isFetchCountriesCalled = false
    var completeCountries: [Country] = [Country]()
    var completeClosure: (([Country]?, Error?) -> ())!
    
    func fetchCountries(searchText: String?, searchType: String?, complete: @escaping (([Country]?, Error?) -> ())) {
        isFetchCountriesCalled = true
        completeClosure = complete
    }
    
    func fetchSuccess() {
        completeClosure( completeCountries, nil )
    }
    
    func fetchFail(error: Error?) {
        completeClosure( nil, error )
    }
}

class StubGenerator {
    func stubCountries() -> [Country] {
        guard let path = Bundle(for: type(of: self)).url(forResource: "content", withExtension:"json")?.path else {
            fatalError("json file not found")
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let countries = try! decoder.decode([Country].self, from: data)
        return countries
    }
}
