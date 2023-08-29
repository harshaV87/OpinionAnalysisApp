//
//  CustomFontModifier.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 10/30/23.
//

import Foundation
import SwiftUI

struct CustomFontModifier: ViewModifier {
   
    func body(content: Content) -> some View {
        content.font(.custom("AmericanTypewriter", size: 16))
    }
}
