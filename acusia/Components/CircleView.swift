//
//  CircleView.swift
//  InstagramTransition
//
//  Created by decoherence on 5/4/24.
//

import SwiftUI

struct CircleView: View {
    var hexColor: String
    var width: CGFloat
    var height: CGFloat
    var startRadius: CGFloat
    var endRadius: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: hexColor), .clear]),
                    center: .center,
                    startRadius: startRadius,
                    endRadius: endRadius
                )
            )
            .frame(width: width, height: height)
            .blur(radius: 64)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
