//
//  Blur.swift
//  acusia
//
//  Created by decoherence on 8/17/24.
//
/// In case this ends up being a private API, use Janum Trivdei's implementation
/// outlined here ` https://designcode.io/swiftui-handbook-progressive-blur `

import SwiftUI

public extension UIBlurEffect {
    static func variableBlurEffect(radius: Double, imageMask: UIImage) -> UIBlurEffect? {
        let methodType = (@convention(c) (AnyClass, Selector, Double, UIImage) -> UIBlurEffect).self
        let selectorName = ["imageMask:", "effectWithVariableBlurRadius:"].reversed().joined()
        let selector = NSSelectorFromString(selectorName)

        guard UIBlurEffect.responds(to: selector) else { return nil }

        let implementation = UIBlurEffect.method(for: selector)
        let method = unsafeBitCast(implementation, to: methodType)

        return method(UIBlurEffect.self, selector, radius, imageMask)
    }
}

struct LinearGradientMask: View {
    var gradientColors: [Color]

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct VariableBlurView: UIViewRepresentable {
    let radius: Double
    let gradientColors: [Color]

    func makeUIView(context: Context) -> UIVisualEffectView {
        let maskView = LinearGradientMask(gradientColors: gradientColors)
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
        let maskView = LinearGradientMask(gradientColors: gradientColors)
        let renderer = ImageRenderer(content: maskView)
        if let maskImage = renderer.uiImage {
            view.effect = UIBlurEffect.variableBlurEffect(radius: radius, imageMask: maskImage)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(0 ..< 3) { _ in
            Circle()
                .foregroundStyle(.red)
        }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .overlay(
        VariableBlurView(radius: 10, gradientColors: [.clear, .black])
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: 240)
            .border(Color.black, width: 1)
    )
}
