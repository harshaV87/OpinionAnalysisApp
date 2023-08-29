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
        
        // now, to extract the youtube, we nee do get the array here
        
        let urlArray = Array(urlString)
        
        // lets iterate through it now
        
        var vArrays = [Int]()
        
        for i in 0..<urlArray.count {
            // now the condition goes that we have to find the subArray where we need to get the v=
            if urlArray[i] == "v" {
                // lets make an array and add it to the array here
                // lets write a check to make sure the program does not crash
                
                if i < urlArray.count - 1 {
                    vArrays.append(i)
                }
               
            }
        }
        
        // now that we have the list of places we have the v, we just need to check iof there is an == after that or ? before that
        
        // now lets iterate through again
        
        let isolatedV = vArrays.filter({urlArray[$0 + 1] == "="})
        
       
        
        if isolatedV.count == 1 {
            // we expect only 1 isolatedvs here
            var stringOutput = urlArray[(isolatedV[0] + 2)...(isolatedV[0] + 12)]
            return String(stringOutput)
        }
        return "Error"
    }
}
