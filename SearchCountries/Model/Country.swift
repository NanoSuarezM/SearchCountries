//
//  Country.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation

struct Countries: Codable {
    let countries: [Country]
}

struct Country: Codable {
    let name: String
    let code: String
    let currency: [Currency]?
    let language: [Languages]
    let capital: String?
    let region: String?
    let area: Double?
    let flag_url: String?
    let latitudeLongitude: [Double]
    var distance: Double = 0
    let population: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case code = "alpha3Code"
        case currency = "currencies"
        case language = "languages"
        case capital
        case region
        case area
        case flag_url = "flag"
        case latitudeLongitude = "latlng"
        case population
    }
}

struct Currency: Codable {
    let code: String?
    let name: String?
    let symbol: String?
}

struct Languages: Codable {
    let iso639_1: String?
    let iso639_2: String?
    let name : String?
    let nativeName: String?
}
