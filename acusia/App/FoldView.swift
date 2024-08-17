//
//  FoldView.swift
//  acusia
//
//  Created by decoherence on 8/16/24.
//
import SwiftUI
import CoreMotion
import Wave

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

    var squeezeCenterX: CGFloat
    var squeezeProgressX: CGFloat
    var squeezeProgressY: CGFloat
    var squeezeTranslationY: CGFloat

    init(squeezeProgressX: CGFloat, squeezeProgressY: CGFloat, squeezeTranslationY: CGFloat, squeezeCenterX: CGFloat, offset: CGSize) {
        self.squeezeProgressX = squeezeProgressX
        self.squeezeProgressY = squeezeProgressY
        self.squeezeTranslationY = squeezeTranslationY
        self.squeezeCenterX = squeezeCenterX
        self.offset = offset
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
            .offset(offset)
    }
}

struct FoldView: View {
    // Interactions
    @State var dragTrigger = false
    @State var glareTrigger = false
    
    @State var offset: CGSize = .zero
    @State var initialLocation: CGPoint = .zero
    @State var previousOffset: CGSize = .zero
    
    @State var previousRotation: Angle = .degrees(0)
    
    // Mesh Transform
    @State var squeezeProgressX: CGFloat = 1.0
    @State var squeezeProgressY: CGFloat = 1.0
    
    func mapRange(_ value: CGFloat, _ inputMin: CGFloat, _ inputMax: CGFloat, _ outputMin: CGFloat, _ outputMax: CGFloat) -> CGFloat {
        return outputMin + (outputMax - outputMin) * (value - inputMin) / (inputMax - inputMin)
    }
    
    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                // Adjust squeeze progress based on pinch
                let newSqueezeProgress = mapRange(value, 0.5, 1.5, 0.0, 1.0)
                
                squeezeProgressX = newSqueezeProgress
                squeezeProgressY = newSqueezeProgress
                
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = true
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0)) {
                    glareTrigger = true
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = false
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0).delay(0.1)) {
                    glareTrigger = false
                }
                withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                    squeezeProgressX = 1
                    squeezeProgressY = 1
                }
            }

        let dragGesture = DragGesture()
            .onChanged { value in
                if initialLocation == .zero {
                    initialLocation = value.startLocation
                }
                
                let xOffset = value.translation.width
                let yOffset = value.translation.height
                
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0)) {
                    offset.width = previousOffset.width + xOffset
                    offset.height = previousOffset.height + yOffset
                }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = true
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0)) {
                    glareTrigger = true
                }
            }
            .onEnded { state in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0)) {
                    previousOffset = offset
                }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = false
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0).delay(0.1)) {
                    glareTrigger.toggle()
                }
            }

        let rotationGesture = RotationGesture()
            .onChanged { value in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = true
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0)) {
                    glareTrigger = true
                }
            }
            .onEnded { (value) in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = false
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0).delay(0.1)) {
                    glareTrigger = false
                }
            }
        
        let combinedGestures = magnificationGesture
            .simultaneously(with: dragGesture)
            .simultaneously(with: rotationGesture)
        
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .fill(Color.white)
                .frame(width: .infinity, height: .infinity)
                .overlay(
                    VStack {
                        VStack {
                            Text("FoldView")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.red)
                        
                        VStack {
                            Text("FoldView")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.green)
                    }
                )
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(MeshTransform(
                    squeezeProgressX: squeezeProgressX,
                    squeezeProgressY: squeezeProgressY,
                    squeezeTranslationY: 0.0,
                    squeezeCenterX: 0.0,
                    offset: offset
                ))
                .gesture(combinedGestures)
        }
    }
}

#Preview {
    FoldView()
}
