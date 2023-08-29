//
//  APILayer.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 8/30/23.
//

import Foundation


// lets get the request method

enum RequestMethod: String {
    case get = "GET"
    // we can extend it like as such
    // case put = "PUT"
}


// protocol endpointprovider

protocol EndpointProvider {
    // declaring the properties
    
    var scheme: String {get}
    var baseURL: String {get}
    var path: String {get}
    var method: RequestMethod {get}
    var token: String {get}
    var queryItems: [URLQueryItem]? {get}
    var body: [String: Any]? {get}
    var mockFile: String? {get}
}

// now lets write an extension to the network service

extension EndpointProvider {
    var scheme: String {
        return "https"
    }
    
    var baseURL: String {
        return "youtube.googleapis.com"
    }
    
    var token: String {
        // u need to return a token here
        return ""
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = baseURL
        urlComponents.path =  path
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        guard let url = urlComponents.url else {
            throw NetworkError.urlComponentsError
        }
        var urlRequest = URLRequest(url: url)
        // lets configure the url request parms now
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !token.isEmpty {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // giving the request body
        if let body = body {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                throw NetworkError.jsonSerialisationError(error.localizedDescription)
            }
        }
        // now we finally return that url request
        return urlRequest
    }
}
