//
//  APIClient.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 8/30/23.
//

import Foundation
import Combine

protocol ApiProtocol {
    func asyncRequest<T: Decodable>(endPoint: EndpointProvider, responseModel: T.Type) async throws -> T
    func combineRequest<T: Decodable>(endPoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, NetworkError>
}


final class ApiClient: ApiProtocol {
    
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300
        return URLSession(configuration: configuration)
    }
    
    
    
    
    func asyncRequest<T>(endPoint: EndpointProvider, responseModel: T.Type) async throws -> T where T : Decodable {
        do {
            let (data, response) = try await session.data(for: endPoint.asURLRequest())
            return try self.manageResponse(data: data, response: response)
        } catch let error as ApiError {
            throw NetworkError.asyncApiErrorFailureWithError(error.localizedDescription)
        } catch {
            throw NetworkError.asyncApiErrorFailure
        }
    }
    
    func combineRequest<T>(endPoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        do {
            return session.dataTaskPublisher(for: try endPoint.asURLRequest()).tryMap { output in
                return try self.manageResponse(data: output.data, response: output.response)
            }.mapError{
                $0 as? NetworkError ?? NetworkError.combineApiErrorFailure
            }.eraseToAnyPublisher()
        } catch let error as NetworkError {
            return AnyPublisher<T, NetworkError>(Fail(error: error))
        } catch {
            return AnyPublisher<T, NetworkError>(Fail(error: error as? NetworkError ?? NetworkError.combineApiErrorFailure))
        }
    }
    
    
    
    // managed response
    
    private func manageResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.jsonURLresponseError("Invalid HTTP response")
        }
        switch response.statusCode {
            // here is where u can add different status codes so that u can account for all kinds of errors
        case 200...299 :
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.responseStatusCodeFailError(error.localizedDescription)
            }
        default:
            guard let decodedError = try? JSONDecoder().decode(ApiError.self, from: data) else {
                throw NetworkError.defaultStatusCodeFailError
            }
            if response.statusCode == 403 && decodedError.errorCode == "expired token" {
                // here we can have a notification center to log the user out of here
            }
            throw NetworkError.defaultStatusCodeFailError
        }
    }
}








protocol Mockable: AnyObject {
    var bundle: Bundle { get }
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T
}

extension Mockable {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }

        do {
            let data = try Data(contentsOf: path)
            let decodedObject = try JSONDecoder().decode(type, from: data)

            return decodedObject
        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}

class MockApiClient: Mockable, ApiProtocol {
    func combineRequest<T>(endPoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        return Just(loadJSON(filename: endPoint.mockFile!, type: responseModel.self) as T)
            .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
    }
    

    func asyncRequest<T>(endPoint endpoint: EndpointProvider, responseModel: T.Type) async throws -> T where T: Decodable {
        return loadJSON(filename: endpoint.mockFile!, type: responseModel.self)
    }

    
}
