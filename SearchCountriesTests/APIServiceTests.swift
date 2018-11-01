//
//  APIServiceTests.swift
//  SearchCountriesTests
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import XCTest
@testable import SearchCountries

//MARK: MOCK
class MockURLSession: URLSessionProtocol {
    
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        
        completionHandler(nextData, successHttpURLResponse(request: request), nextError)
        return nextDataTask
    }
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}



class APIServiceTests: XCTestCase {
    var sut: APIService!
    var session = MockURLSession()
    
    override func setUp() {
        super.setUp()
        
        sut = APIService(session: session)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    //The apiService should submit the request with the same URL as the assigned one.
    func testRequestALLCountriesWithSameURL() {
        guard let url = URL(string: "https://restcountries.eu/rest/v2/all") else  {
            fatalError("URL can't be empty")
        }
        sut.fetchCountries(searchText: nil, searchType: nil) { (response, error) in
        }
        
        XCTAssert(session.lastURL == url)
    }
    
    func testRequestCountryByNameWithSameURL() {
        
        guard let url = URL(string: "https://restcountries.eu/rest/v2/name/Spain") else  {
            fatalError("URL can't be empty")
        }
        
        sut.fetchCountries(searchText: "Spain", searchType: "Name") { (response, error) in
        }
        XCTAssert(session.lastURL == url)
    }
    
    func testRequestCountryByCapitalWithSameURL() {
        
        guard let url = URL(string: "https://restcountries.eu/rest/v2/capital/Madrid") else  {
            fatalError("URL can't be empty")
        }
        
        sut.fetchCountries(searchText: "Madrid", searchType: "Capital") { (response, error) in
            // return data
        }
        //        httpClient.get(url: url) { (success, response) in
        //            // Return data
        //        }
        
        XCTAssert(session.lastURL == url)
    }
    
    func testRequestCountryByLanguageWithSameURL() {
        
        guard let url = URL(string: "https://restcountries.eu/rest/v2/lang/ES") else  {
            fatalError("URL can't be empty")
        }
        
        sut.fetchCountries(searchText: "ES", searchType: "Language") { (response, error) in
            // return data
        }
        //        httpClient.get(url: url) { (success, response) in
        //            // Return data
        //        }
        
        XCTAssert(session.lastURL == url)
    }
    
    func testRequestCountryByRegionWithSameURL() {
        
        guard let url = URL(string: "https://restcountries.eu/rest/v2/regionalbloc/EU") else  {
            fatalError("URL can't be empty")
        }
        
        sut.fetchCountries(searchText: "EU", searchType: "Region") { (response, error) in
            // return data
        }
        //        httpClient.get(url: url) { (success, response) in
        //            // Return data
        //        }
        
        XCTAssert(session.lastURL == url)
    }
    
    func testRequestCountryByCurrencyWithSameURL() {
        
        guard let url = URL(string: "https://restcountries.eu/rest/v2/currency/EUR") else  {
            fatalError("URL can't be empty")
        }
        
        sut.fetchCountries(searchText: "EUR", searchType: "Currency") { (response, error) in
            // return data
        }
        //        httpClient.get(url: url) { (success, response) in
        //            // Return data
        //        }
        
        XCTAssert(session.lastURL == url)
    }
    
    func testGetResumeCalled() {
        let dataTask = MockURLSessionDataTask()
        session.nextDataTask = dataTask
        
        sut.fetchCountries(searchText: nil, searchType: nil) { (response, error) in
            // return data
        }
        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func testGetShouldReturnData() {
        
        let expectedCountry = self.countryByName()
        
        guard let path = Bundle(for: type(of: self)).url(forResource: "content", withExtension:"json")?.path else {
            fatalError("json file not found")
        }
        let expectedData = try! Data(contentsOf: URL(fileURLWithPath: path))
        session.nextData = expectedData
        
        var actualData: [Country]?
        sut.fetchCountries(searchText: "Spain", searchType: "Name") { (response, error) in
            actualData = response
        }
        
        XCTAssertNotNil(actualData)
        
        if let name = actualData?[0].name {
            XCTAssertTrue(name == expectedCountry.name)
        }
    }
    
    func countryByName() -> Country {
        let languages = Languages(iso639_1: "es", iso639_2: "spa", name: "Spanish", nativeName: "Español")
        let currency = Currency(code: "EUR", name: "Euro", symbol: "€")
        return Country(name: "Spain", code: "ESP", currency: [currency], language: [languages], capital: "Madrid", region: "Europe", area: 505992.0, flag_url: "https://restcountries.eu/data/esp.svg", latitudeLongitude:[40.0,-4.0], distance: 0, population: 46438422)
    }
}
