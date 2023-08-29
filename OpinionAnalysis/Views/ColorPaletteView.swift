//
//  ColorPaletteView.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 10/10/23.
//

import SwiftUI

struct ColorPaletteView: View {
    var body: some View {
        VStack{
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.gray, Color.green]), startPoint: .leading, endPoint: .trailing).frame(height: 50)
                HStack {
                    Text("Negative").foregroundColor(.black).padding(.leading, 20)
                    Text("Neutral").foregroundColor(.black).padding(20)
                    Text("Positive").foregroundColor(.black).padding(.trailing, 20)
                }
            }
        }.cornerRadius(20)
    }
}

struct ColorPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPaletteView()
    }
}
