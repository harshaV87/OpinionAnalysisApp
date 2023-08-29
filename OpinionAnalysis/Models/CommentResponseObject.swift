//
//  CommentResponseObject.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 9/4/23.
//

import Foundation

// MARK: - CommentResponse
struct CommentResponse: Codable {
    let kind, etag, nextPageToken: String
    let pageInfo: PageInfo
    let items: [Item]
}

// MARK: - Item
struct Item: Codable, Identifiable {
    let kind, etag, id: String
    let snippet: ItemSnippet
}

// MARK: - ItemSnippet
struct ItemSnippet: Codable {
    //let channelID, videoID: String
    let topLevelComment: TopLevelComment
//    let canReply: Bool
//    let totalReplyCount: Int
//    let isPublic: Bool

    enum CodingKeys: String, CodingKey {
//        case channelID = "channelId"
//        case videoID = "videoId"
        case topLevelComment
            // case canReply, totalReplyCount, isPublic
    }
}

// MARK: - TopLevelComment
struct TopLevelComment: Codable, Identifiable  {
    let kind, etag, id: String
    let snippet: TopLevelCommentSnippet
}

// MARK: - TopLevelCommentSnippet
struct TopLevelCommentSnippet: Codable  {
   // let channelID, videoID: String
    let textDisplay: String
        let textOriginal: String
    //let authorDisplayName: String
    //let authorProfileImageURL: String
//    let authorChannelURL: String
//    let authorChannelID: AuthorChannelID
//    let canRate: Bool
//    let viewerRating: String
//    let likeCount: Int
//    let publishedAt, updatedAt: Date

    enum CodingKeys: String, CodingKey {
//        case channelID = "channelId"
//        case videoID = "videoId"
        case textDisplay
             case textOriginal
                 // case authorDisplayName
        //case authorProfileImageURL = "authorProfileImageUrl"
//        case authorChannelURL = "authorChannelUrl"
//        case authorChannelID = "authorChannelId"
//        case canRate, viewerRating, likeCount, publishedAt, updatedAt
    }
}

// MARK: - AuthorChannelID
struct AuthorChannelID: Codable {
    let value: String
}

// MARK: - PageInfo
struct PageInfo: Codable {
    let totalResults, resultsPerPage: Int
}

// Image resizing - https://www.resizepixel.com/edit
