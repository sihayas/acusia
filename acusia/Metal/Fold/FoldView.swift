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
        Shader(function: .init(library: .default, name: "fold"), arguments: [
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
                // Adjust the starting value to reflect a smooth transition from the current state
                let newSqueezeProgress = mapRange(value, 1.0, 1.5, squeezeProgressX, 0.0)
                
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
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            Rectangle()
                .fill(Color.black)
                .aspectRatio(9 / 19.5, contentMode: .fit)  // Aspect ratio for modern iPhones (19.5:9)
                .overlay(
                    VStack(spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            VStack(alignment: .leading, spacing: 0) {
                                Image("heartbreak")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.red)
                                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 4)
                                    .padding(.bottom, 12)
                                
                                Text("Florence + The Machine")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.secondary)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                Text("High As Hope")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 12)
                                
                                Text("I'm not really sure what I have to say about this other than that it's good. It's not nearly as bulletproof as RENAISSANCE was, but that's fine when you're making as sprawling and grand an artistic statement as this. It's probably more of an album that I respect rather than one that I just totally love listening to, but the extensive list of favorites I have for it suggests that it might actually just be that good. Excited for Act 3.")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 15, weight: .regular))
                                    .multilineTextAlignment(.leading)
                                
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .background(.black)
                        }
                        
                        AsyncImage(url: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/76/96/d1/7696d110-c929-4908-8fa1-30aad2511c55/00602567485872.rgb.jpg/600x600bb.jpg")!) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                )
                .frame(maxWidth: 264)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
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
