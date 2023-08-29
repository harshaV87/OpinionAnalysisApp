//
//  CommentsViewModel.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 8/30/23.
//

import Foundation
import Combine
import SwiftUI

final class CommentsViewModel: ObservableObject {
    // MARK: Properties
    let apiClient: ApiProtocol
    let sentimentClient: SentimentService
    var videoUrl: String = ""
    var maxValues: String = ""
    @Published var commentError: NetworkError?
    private var cancellables: Set<AnyCancellable> = []
    @Published var commentsList: [Item] = []
    @Published var commentDict: [String: String] = [:]
    @Published var loading = false
    
    // MARK: Init - Api client and Sentiment Analysis
    init(apiClient: ApiProtocol = ApiClient(), sentimentAnalysis: SentimentService = SentimentAnalysis()) {
        self.apiClient = apiClient
        self.sentimentClient = sentimentAnalysis
    }
    
    
    @MainActor // MARK: Actual Usage to get comments
    func getCommentsFromOrigin() async {
        self.loading = true
        let endpoint = OpinionEndPoints.getComments(videoId: videoUrl, maxValues: maxValues)
        Task.init {
            do {
                let comments = try await apiClient.asyncRequest(endPoint: endpoint, responseModel: CommentResponse.self)
                commentsList = comments.items
                _ = comments.items.map{commentDict[$0.snippet.topLevelComment.snippet.textOriginal] = sentimentClient.giveSentimentScore(inputString: $0.snippet.topLevelComment.snippet.textOriginal)}
                self.loading = false
            } catch let error as NetworkError {
               // lets show the error here
                commentError = error
                self.loading = false
            }
        }
        
        
    }
    
    func getCombineEvents() { // MARK: Extra implementation
        let endpoint = OpinionEndPoints.getComments(videoId: videoUrl, maxValues: maxValues)
        apiClient.combineRequest(endPoint: endpoint, responseModel: CommentResponse.self)
                .receive(on: DispatchQueue.main) // 5
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.commentError = error
                    }
                } receiveValue: { [weak self] events in
                    guard let self = self else { return }
                    // this can also be used to get the events from the combine framework
                }
                .store(in: &cancellables)
        }
    
    // MARK: Color gradients
    func getColorGradients(givenScore: Double) -> LinearGradient {
        switch givenScore {
        case _ where givenScore == 0.0 : return
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color.gray, location: givenScore)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case _ where givenScore < 0.0  : return
            
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color.orange, location: givenScore)
               // .init(color: Color.orange, location: givenScore)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case _ where givenScore > 0.0 : return
          
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color.green, location: givenScore)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            default : return
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color.gray, location: givenScore),
                .init(color: Color.orange, location: givenScore)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}




