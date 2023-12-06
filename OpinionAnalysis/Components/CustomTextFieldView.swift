//
//  CustomTextFieldView.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 6/26/23.
//

import SwiftUI

struct CustomTextFieldView: View {
    // child view binding
    @Binding var textInput: String
    @State var isSecureFromButton: Bool = true
    let title: String
    let placeHolderText : String
    var isSecureTextField: Bool = false
    var body: some View {
           // label, textview and a placeholder
        VStack(alignment: .leading, spacing: 5.0) {
            Text(title).font(
                .custom(
                "AmericanTypewriter",
                fixedSize: 16)
                //.weight(.light)
            )
      // secure text field
            if isSecureTextField {
                HStack {
                    ZStack {
                        Group {
                            if isSecureFromButton {
                                SecureField(placeHolderText, text: $textInput)      
                            } else {
                                TextField(placeHolderText, text: $textInput).modifier(CustomFontModifier())      
                            }
                        }       
                    }   
                    Button {
                        isSecureFromButton.toggle()
                    } label: {
                        Image(systemName: self.isSecureFromButton ? "eye.slash" : "eye")
                    } .padding(.trailing, 8)
                }
               // SecureField(placeHolderText, text: $textInput)
                Rectangle().frame(height: 1).foregroundColor(.secondary)
            } else {
                TextField(placeHolderText, text: $textInput).font(
                    .custom(
                    "AmericanTypewriter",
                    fixedSize: 16)).onReceive(textInput.publisher) { publish in
                        print("the print here is \(publish)")
                        }
                Rectangle().frame(height: 1).foregroundColor(.secondary)
            }
        }.padding()
    }
}

struct CustomTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextFieldView(textInput: .constant(""), title: "Title", placeHolderText: "Please enter your placeholder text")
    }
}

