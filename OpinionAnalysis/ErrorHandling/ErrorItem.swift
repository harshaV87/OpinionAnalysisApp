//
//  ErrorItem.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 11/8/23.
//

import Foundation

import Foundation


struct ErrorItem: Identifiable {
    let id: UUID
    let error : Error
    init(error: Error) {
        self.id = UUID()
        self.error = error
    }
}
