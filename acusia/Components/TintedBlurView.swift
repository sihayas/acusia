//
//  BlackBlurView.swift
//  acusia
//
//  Created by decoherence on 9/8/24.
//
import SwiftUI

struct TintedBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var backgroundColor: UIColor
    var blurMutingFactor: CGFloat = 0.5

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false

        // Create and add the vibrancy effect view
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = blurEffectView.bounds
        vibrancyEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.contentView.addSubview(vibrancyEffectView)

        // Insert the blur effect view
        DispatchQueue.main.async {
            // Try to access the tinting subview directly to apply background color
            if let tintingView = blurEffectView.subviews.first(where: {
                String(describing: type(of: $0)) == "_UIVisualEffectSubview"
            }) {
                tintingView.backgroundColor = backgroundColor.withAlphaComponent(blurMutingFactor)
            } else {
                // Fallback if the tinting subview isn't found
                let color = backgroundColor.withAlphaComponent(blurMutingFactor)
                let fallbackBackgroundView = UIView(frame: blurEffectView.bounds)
                fallbackBackgroundView.backgroundColor = color
                fallbackBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blurEffectView.contentView.addSubview(fallbackBackgroundView)
            }
        }

        return blurEffectView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // No updates needed for now
    }
}

// UnevenRoundedRectangle(topLeadingRadius: cornerRadius * 0.75, bottomLeadingRadius: cornerRadius * 0.75, bottomTrailingRadius: cornerRadius, topTrailingRadius: cornerRadius, style: .continuous)
//    .stroke(.white.opacity(0.1), lineWidth: 1)
//    .foregroundStyle(.clear)
//    .background(
//        BlurView(style: .dark, backgroundColor: .black, blurMutingFactor: 1.0)
//            .edgesIgnoringSafeArea(.all)
//    )
//    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//    .edgesIgnoringSafeArea(.all)


// TintedBlurView(style: .systemChromeMaterialDark, backgroundColor: .black, blurMutingFactor: 0.5)
//     .edgesIgnoringSafeArea(.all)
