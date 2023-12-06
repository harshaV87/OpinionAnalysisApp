//
//  VideoIDExtraction.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 9/6/23.
//

import Foundation
import UIKit


class extractIDFromURL {
    static let extract = extractIDFromURL()
    
    func getIDFromURL(from urlString: String) -> String {
        // an example here is https://www.youtube.com/watch?v=0MTjHRW5WtU&ab_channel=VivekRamaswamy
        // Extract chars as array
        let urlArray = Array(urlString)
        //iterate through it now
        var vArrays = [Int]()
        // Loop through
        for i in 0..<urlArray.count {
            // condition for subArray to get the v=
            if urlArray[i] == "v" {
        // redundancy for no crash 
                if i < urlArray.count - 1 {
                    vArrays.append(i)
                } 
            }
        }
        //  v places check for an == after that or ? before that
        // iterate through again
        let isolatedV = vArrays.filter({urlArray[$0 + 1] == "="})
        // sub arrays 
        if isolatedV.count == 1 {
            // we expect only 1 isolatedvs here
            var stringOutput = urlArray[(isolatedV[0] + 2)...(isolatedV[0] + 12)]
            return String(stringOutput)
        }
        return "Error"
    }
}
