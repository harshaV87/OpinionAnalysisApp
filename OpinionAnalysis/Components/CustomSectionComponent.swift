//
//  CustomSectionComponent.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 6/27/23.
//

import SwiftUI

struct CustomSectionComponent: View {
    let imageName: String
    let textName: String
    let versionNumber: String
    let tintColor: Color
    var body: some View {
        // Image
        // text
        // text - hstack
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: imageName).imageScale(.small).font(.title).foregroundColor(tintColor)
            Text(textName).foregroundColor(.primary).modifier(CustomFontModifier())
            Spacer()
            Text(versionNumber)
        }.padding()
    }
}

struct CustomSectionComponent_Previews: PreviewProvider {
    static var previews: some View {
        CustomSectionComponent(imageName: "gear", textName: "Version", versionNumber: "1.0.9", tintColor: Color(.systemGray))
    }
}

