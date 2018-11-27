//
//  APIService.swift
//  SearchCountries
//
//  Created by Nano Suarez on 01/11/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation

enum SearchType: String {
    case Name
    case Capital
    case Language
    case Region
    case Currency
    case All
}

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> ()
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

protocol APIServiceProtocol {
    func fetchCountries(searchText:String?, searchType: String?, complete: @escaping (( _ data: [Country]?, _ error: Error?)->()))
}

final class APIService: APIServiceProtocol {
    typealias completeClosure = ( _ data: [Country]?, _ error: Error?)-> ()
    private let session: URLSessionProtocol
    
    init() {
        self.session = URLSession.shared
    }
    
    //I use this init for unit testing, dependency injection of session
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func fetchCountries(searchText:String?, searchType: String?, complete: @escaping completeClosure){
        
        let urlString = self.urlStringFrom(searchText: searchText, searchType: searchType)
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                if let Responserror = error {
                    complete(nil, Responserror)
                }
            }
            
            guard let responseData = data else { return }
            
            do {
                //Decode retrived data with JSONDecoder and assing type of Country object
                let countriesData = try JSONDecoder().decode([Country].self, from: responseData)
                complete(countriesData, nil)
                
            } catch let jsonError {
                complete(nil, jsonError)
            }
        }
        task.resume()
    }
    
    func urlStringFrom(searchText: String?, searchType: String?) -> String{
        let endpoints = Endpoints()
        guard let searchText = searchText else { return endpoints.allEndpoint}
        // in case the search text has more than 1 word we need to put %20 between the words
        let text = searchText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        switch searchType {
        case "Name":
            return "\(endpoints.nameEndpoint)\(text)"
        case "Capital":
            return "\(endpoints.capitalEndpoint)\(text)"
        case "Language":
            return "\(endpoints.languageEndpoint)\(text)"
        case "Region":
            return "\(endpoints.regionEndpoint)\(text)"
        case "Currency":
            return "\(endpoints.currencyEndpoint)\(text)"
        default:
            return endpoints.allEndpoint
        }
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

//MARK: Conform the protocol
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}
