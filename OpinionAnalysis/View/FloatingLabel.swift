//
//  FloatingLabel.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 9/6/23.
//

import Foundation
import Combine
import SwiftUI

public struct FloatingLabelInput: View {
    let textFieldHeight: CGFloat = 50
    private let placeHolderText: String
    @Binding var text: String
    @State private var isEditing = false
    public init(placeHolderText: String, text: Binding<String>) {
        self._text = text
        self.placeHolderText = placeHolderText
    }
    
    var shouldPlaceHolderMove: Bool {
        !isEditing || (text.count != 0 )
       
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
                    TextField("", text: $text, onEditingChanged: { (edit) in
                        //isEditing = edit
                    })
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary, lineWidth: 1)
                    .frame(height: textFieldHeight))
                    .foregroundColor(Color.primary)
                    .accentColor(Color.secondary)
                    .animation(.linear, value: 0)
                    ///Floating Placeholder
                    Text(placeHolderText)
                    .foregroundColor(Color.secondary)
                        .background(Color(UIColor.systemBackground))
                    .padding(shouldPlaceHolderMove ?
                             EdgeInsets(top: 0, leading:15, bottom: textFieldHeight, trailing: 0) :
                             EdgeInsets(top: 0, leading:15, bottom: 0, trailing: 0))
                    .scaleEffect(shouldPlaceHolderMove ? 1.0 : 1.2).animation(.linear, value: 0)
                    
                }
    }
}
