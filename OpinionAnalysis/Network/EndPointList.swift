//
//  EndPointList.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 8/30/23.
//

import Foundation

enum OpinionEndPoints: EndpointProvider {
case getComments(videoId: String, maxValues: String)
case getCaptions(videoId: String)
    // other cases
    
    // https://www.googleapis.com/youtube/v3/captions/\(captionId)?key=\(apiKey)"
    // "https://www.googleapis.com/youtube/v3/captions?part=snippet&videoId=\(videoId)&key=\(apiKey)"
    
    var path: String {
        switch self {
        case .getComments(_,_):
            return "/youtube/v3/commentThreads"
            
        case .getCaptions(_):
        return "/youtube/v3/captions"
        }
        
    }
    
    var method: RequestMethod {
        switch self {
        case .getComments(_,_):
            return .get
        case .getCaptions(_):
            return .get
        }
        
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getComments(let videoID, let maxValues) :
            // example - _WyfsRVgk2Q
            return [URLQueryItem(name: "part", value: constants.partValue), URLQueryItem(name: "maxResults", value: maxValues), URLQueryItem(name: "videoId", value: videoID), URLQueryItem(name: "key", value: constants.API_Key)]
            
        case .getCaptions(let videoID):
        return  [URLQueryItem(name: "part", value: constants.partValue), URLQueryItem(name: "videoId", value: videoID), URLQueryItem(name: "key", value: constants.API_Key)]
        
        }
    }
    
    var body: [String : Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    var mockFile: String? {
        // MARK: THIS IS WHAT YOU WOULD WANT TO INJECT INTO THE MOCK TO GET THE TESTS DONE
        switch self {
            // EXAMPLE
        case .getComments(_,_) :
                    return "_getEventsMockResponse"
        case .getCaptions(_) :
            return ""
        
        }
    }
    
    
}


extension Encodable {
    var toDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {return nil}
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
