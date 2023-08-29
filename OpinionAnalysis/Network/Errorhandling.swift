//
//  Errorhandling.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 8/30/23.
//

import Foundation

// as error is a protocol , we can conform to it as an enum

enum NetworkError: Error {
    case urlComponentsError
    case otherError
    case jsonSerialisationError(String)
    case jsonURLresponseError(String)
    case responseStatusCodeFailError(String)
    case defaultStatusCodeFailError
    case asyncApiErrorFailure
    case combineApiErrorFailure
    case asyncApiErrorFailureWithError(String)
}


struct ApiError: Error {

    var statusCode: Int!
    let errorCode: String
    var message: String

    init(statusCode: Int = 0, errorCode: String, message: String) {
        self.statusCode = statusCode
        self.errorCode = errorCode
        self.message = message
    }

    var errorCodeNumber: String {
        let numberString = errorCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return numberString
    }

    private enum CodingKeys: String, CodingKey {
        case errorCode
        case message
    }
}

extension ApiError: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try container.decode(String.self, forKey: .errorCode)
        message = try container.decode(String.self, forKey: .message)
    }
}
