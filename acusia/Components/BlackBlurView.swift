//
//  BlackBlurView.swift
//  acusia
//
//  Created by decoherence on 9/8/24.
//
import SwiftUI

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var backgroundColor: UIColor
    var blurMutingFactor: CGFloat = 0.5
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        blurEffectView.isUserInteractionEnabled = false
        
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


// Example
//BlurView(style: .dark, backgroundColor: .black, blurMutingFactor: 0.75)
//    .edgesIgnoringSafeArea(.all)
