//
//  RadialBlur.swift
//  acusia
//
//  Created by decoherence on 12/11/24.
//

import SwiftUI

struct RadialGradientMask: View {
    var size: CGSize

    var body: some View {
        let maxDimension = max(size.width, size.height)
        let minDimension = min(size.width, size.height)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        RadialGradient(
            gradient: Gradient(colors: [.clear, .red]),
            center: UnitPoint(
                x: center.x / size.width,
                y: center.y / size.height
            ),
            startRadius: minDimension / 4, // Smaller radius to ensure visibility
            endRadius: maxDimension / 2   // Scaled properly for large dimensions
        )
        .frame(width: size.width, height: size.height)
    }
}

struct RadialVariableBlurView: UIViewRepresentable {
    let radius: Double
    let size: CGSize

    func makeUIView(context: Context) -> UIVisualEffectView {
        let maskView = RadialGradientMask(size: size)
        let renderer = ImageRenderer(content: maskView)
        if let maskImage = renderer.uiImage {
            let effect = UIBlurEffect.variableBlurEffect(radius: radius, imageMask: maskImage)
            let blurView = UIVisualEffectView(effect: effect)
            return blurView
        } else {
            return UIVisualEffectView(effect: nil)
        }
    }

    func updateUIView(_ view: UIVisualEffectView, context: Context) {
        let maskView = RadialGradientMask(size: size)
        let renderer = ImageRenderer(content: maskView)
        if let maskImage = renderer.uiImage {
            view.effect = UIBlurEffect.variableBlurEffect(radius: radius, imageMask: maskImage)
        }
    }
}
