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
    case hello
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
    
    var body: some View {
        ZStack {
            OGHelloStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex)
                .offset(x: 0, y: -30)
                .zIndex(Double(zIndexMap[.hello] ?? 0))
            
            OGHelloStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex)
                .offset(x: 0, y: 30)
                .zIndex(Double(zIndexMap[.hello] ?? 0))
            
            OGHelloStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex)
                .offset(x: 0, y: 60)
                .zIndex(Double(zIndexMap[.hello] ?? 0))
            
            OGHelloStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex)
                .offset(x: 0, y: 90)
                .zIndex(Double(zIndexMap[.hello] ?? 0))
        }
        .ignoresSafeArea()
    }
}

struct OGHelloStickerView: View {
    // zIndex
    @Binding var zIndexMap: [StickerType: Int]
    @Binding var nextZIndex: Int
    
    // Interactions
    @State var isDragging = false
    
    @State var offset: CGSize = .zero
    @State var initialLocation: CGPoint = .zero
    @State var previousOffset: CGSize = .zero
    
    @State var currentMagnification: CGFloat = 1
    @GestureState var pinchMagnification: CGFloat = 1
    
    @State var currentRotation = Angle.zero
    @GestureState var twistAngle = Angle.zero
    @State var previousRotation: Angle = .degrees(0)
    
    // Mesh Transform
    @State var squeezeProgressX: CGFloat = 1.0
    @State var squeezeProgressY: CGFloat = 1.0
    
    func mapRange(_ value: CGFloat, _ inputMin: CGFloat, _ inputMax: CGFloat, _ outputMin: CGFloat, _ outputMax: CGFloat) -> CGFloat {
        return outputMin + (outputMax - outputMin) * (value - inputMin) / (inputMax - inputMin)
    }
    
    func applySqueezeAnimations(squeezeX: CGFloat, squeezeY: CGFloat, isDragging: Bool) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
            self.isDragging = isDragging
        }
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            squeezeProgressX = squeezeX
        }
        withAnimation(.easeInOut(duration: 1.0).delay(0)) {
            squeezeProgressY = squeezeY
        }
    }
    
    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .updating($pinchMagnification, body: { value, state, _ in
                state = value
            })
            .onChanged { _ in
                applySqueezeAnimations(squeezeX: 0, squeezeY: 0, isDragging: true)
                zIndexMap[.hello] = nextZIndex
                nextZIndex += 1
            }
            .onEnded { value in
                self.currentMagnification *= value
                applySqueezeAnimations(squeezeX: 1, squeezeY: 1, isDragging: false)
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
                applySqueezeAnimations(squeezeX: 0, squeezeY: 0, isDragging: true)
                zIndexMap[.hello] = nextZIndex
                nextZIndex += 1
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0)) {
                    previousOffset = offset
                }
                applySqueezeAnimations(squeezeX: 1, squeezeY: 1, isDragging: false)
            }

        let rotationGesture = RotationGesture()
            .updating($twistAngle, body: { value, state, _ in
                state = value
            })
            .onChanged { _ in
                applySqueezeAnimations(squeezeX: 0, squeezeY: 0, isDragging: true)
                zIndexMap[.hello] = nextZIndex
                nextZIndex += 1
            }
            .onEnded { value in
                self.currentRotation += value
                applySqueezeAnimations(squeezeX: 1, squeezeY: 1, isDragging: false)
            }
        
        let combinedGestures = magnificationGesture
            .simultaneously(with: dragGesture)
            .simultaneously(with: rotationGesture)
        
        let mkShape = MKSymbolShape(imageName: "helloSticker")
        
        ZStack {
            mkShape
                .stroke(.white,
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round, // This makes the stroke ends rounded
                            lineJoin: .round // This makes the stroke joins rounded
                        ))
                .frame(width: 170, height: 56)
           
            Image("helloSticker")
                .resizable()
                .scaledToFill()
                .frame(width: 170, height: 56)
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/ .fill/*@END_MENU_TOKEN@*/)
                .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 0)
        }
        .frame(width: 340, height: 112) // Double sized frame is neccessary because the Shader
        .scaleEffect(1.5) // Because in Shader we scale it down
        .modifier(MeshTransform(
            squeezeProgressX: squeezeProgressX,
            squeezeProgressY: squeezeProgressY,
            squeezeTranslationY: 0.0,
            squeezeCenterX: 0.0,
            offset: offset,
            currentRotation: currentRotation,
            currentMagnification: currentMagnification,
            pinchMagnification: pinchMagnification,
            twistAngle: twistAngle
        ))
        .gesture(combinedGestures)
    }
}
