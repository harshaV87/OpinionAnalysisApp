//
//  SentimentAnalysisService.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 9/4/23.
//

import Foundation
import NaturalLanguage
import UIKit
import SwiftUI

protocol SentimentService {
    func giveSentimentScore(inputString: String) -> String
}

class SentimentAnalysis: SentimentService {
    func giveSentimentScore(inputString: String) -> String {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = modifyTextInput(inputString: inputString)
        let (sentiment, _) = tagger.tag(at: inputString.startIndex, unit: .paragraph, scheme: .sentimentScore)
            return sentiment?.rawValue ?? ""
    }
    
    // MARK: remove the spaces to avoid wrong sentiment values
    private func modifyTextInput(inputString: String) -> String {
        var indexesToDoTheOperations: [Int] = []
        var stringChars = [""]
        _ = inputString.map {stringChars.append(String($0))}
        
        for i in 0..<stringChars.count {
            if (stringChars[i] == "!" || stringChars[i] == ".") && i != stringChars.count - 1 && stringChars[i + 1] == " "{
                // string indexes
                indexesToDoTheOperations.append(i)
            }
        }
        var indexesToDelete : [Int] = []
        for indexOf in indexesToDoTheOperations {
            // all indexes
            var indexCount = indexOf + 1
            while stringChars[indexCount] == " " {
                indexCount += 1
            }
            indexesToDelete.append(contentsOf: indexOf + 1..<indexCount - 1)
        }
        let returnSentence = stringChars
        var finalArrayToReturn = [String]()
        let _ = returnSentence.indices.filter { !indexesToDelete.contains($0) }.map{finalArrayToReturn.append(returnSentence[$0])}
        return finalArrayToReturn.reduce("", +)
    }
    
    
    
}



