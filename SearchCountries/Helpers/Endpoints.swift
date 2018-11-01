//
//  Endpoints.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation

final class Endpoints {
    
    var nameEndpoint: String {
        return "https://restcountries.eu/rest/v2/name/"
    }
    
    var capitalEndpoint: String {
        return "https://restcountries.eu/rest/v2/capital/"
    }
    
    var languageEndpoint: String {
        return "https://restcountries.eu/rest/v2/lang/"
    }
    
    var regionEndpoint: String {
        return "https://restcountries.eu/rest/v2/regionalbloc/"
    }
    
    var currencyEndpoint: String {
        return "https://restcountries.eu/rest/v2/currency/"
    }
    
    var allEndpoint: String {
        return "https://restcountries.eu/rest/v2/all"
    }
}

