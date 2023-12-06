//
//  SecureINPUTvIEW.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 11/8/23.
//

import Foundation
import SwiftUI


struct SecureInputView: View {
    
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
   
    var body: some View {
            ZStack {
                Group {
                    if isSecured {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                    }
                }.padding(.trailing, 32)
                Button {
                    isSecured.toggle()
                } label: {
                    Image(systemName: self.isSecured ? "eye.slash" : "eye").accentColor(.gray)
                }

            }  
    }   
}

