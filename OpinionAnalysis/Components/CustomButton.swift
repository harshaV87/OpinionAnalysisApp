//
//  CustomButton.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 6/27/23.
//

import SwiftUI

struct CustomButton: View {
    var textInput: String = ""
    var iconName: String = ""
    var buttonAction: (() -> Void)
    var backGroundColor: Color?
    var body: some View {
       // text, icon, label and action
        Button {
            buttonAction()
        } label: {
            Text(textInput).foregroundColor(Color.white).frame(width: UIScreen.main.bounds.width - 155, height: 50)
            Image(iconName)
        }.background(backGroundColor).cornerRadius(10)
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(buttonAction: {
        })
    }
}

