//
//  Test.swift
//  acusia
//
//  Created by decoherence on 9/9/24.
//
import CoreMotion
import SwiftUI
import Wave

enum StickerType {
    case hello, ghost
}

#Preview {
    StickerTestView()
}

// Wrap the shader inside a ViewModifier to make the shader values animateable
struct MeshTransform: ViewModifier, Animatable {
    // Ref: https://www.hackingwithswift.com/books/ios-swiftui/animating-complex-shapes-with-animatablepair
    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
        get {
            AnimatableData(AnimatablePair(squeezeProgressX, squeezeProgressY), squeezeTranslationY)
        }
        set {
            squeezeProgressX = newValue.first.first
            squeezeProgressY = newValue.first.second
            squeezeTranslationY = newValue.second
        }
    }

    var offset: CGSize
    var currentRotation: Angle
    var currentMagnification: CGFloat
    var pinchMagnification: CGFloat
    var twistAngle: Angle

    var squeezeCenterX: CGFloat
    var squeezeProgressX: CGFloat
    var squeezeProgressY: CGFloat
    var squeezeTranslationY: CGFloat

    init(squeezeProgressX: CGFloat, squeezeProgressY: CGFloat, squeezeTranslationY: CGFloat, squeezeCenterX: CGFloat, offset: CGSize, currentRotation: Angle, currentMagnification: CGFloat, pinchMagnification: CGFloat, twistAngle: Angle) {
        self.squeezeProgressX = squeezeProgressX
        self.squeezeProgressY = squeezeProgressY
        self.squeezeTranslationY = squeezeTranslationY
        self.squeezeCenterX = squeezeCenterX
        self.offset = offset
        self.currentRotation = currentRotation
        self.currentMagnification = currentMagnification
        self.pinchMagnification = pinchMagnification
        self.twistAngle = twistAngle
    }

    func shader() -> Shader {
        Shader(function: .init(library: .default, name: "distortion"), arguments: [
            .boundingRect,
            .float(squeezeCenterX),
            .float(squeezeProgressX),
            .float(squeezeProgressY),
            .float(squeezeTranslationY)
        ])
    }

    func body(content: Content) -> some View {
        content
            .distortionEffect(shader(), maxSampleOffset: CGSize(width: 500, height: 500))
            .rotationEffect(currentRotation + twistAngle, anchor: .center)
            .offset(offset)
    }
}

struct StickerTestView: View {
    // zIndex
    @State var zIndexMap: [StickerType: Int] = [:]
    @State var nextZIndex: Int = 1

    @State private var zAxisSliderValue: Double = 0
    @State private var xAxisSliderValue: Double = 0
    @State private var offsetSliderValue: Double = 0

    var body: some View {
        ZStack {
            HelloStickerRaw(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex)
                .offset(x: 0, y: -30)
                .zIndex(Double(zIndexMap[.hello] ?? 0))
        }
        .ignoresSafeArea()
        .ignoresSafeArea()
    }
}
