//
//  SwiftStickerView.swift
//  StickerWall
//
//  Created by Daniel Korpai on 12/03/2024.
//  Contact and more details at https://danielkorpai.com
//

import SwiftUI

struct SwiftStickerView: View {
    // zIndex
    @Binding var zIndexMap: [StickerViewType: Int]
    @Binding var nextZIndex: Int
    
    // Interactions
    @State var dragTrigger = false
    @State var glareTrigger = false

    @State var offset: CGSize = .zero
    @State var initialLocation: CGPoint = .zero
    @State var previousOffset: CGSize = .zero
    
    @State var currentMagnification: CGFloat = 1
    @GestureState var pinchMagnification: CGFloat = 1
    
    @State var currentRotation = Angle.zero
    @GestureState var twistAngle = Angle.zero
    @State var previousRotation: Angle = .degrees(0)
    
    // Resetting
    @Binding var resetStickerOffset: Bool
    
    // 3D Config
    @Binding var xAxisSliderValue: Double
    @Binding var zAxisSliderValue: Double
    @Binding var offsetSliderValue: Double
    
    @Binding var activeSticker: StickerViewType?
    
    // Device Motion
    @ObservedObject var motionManager = MotionManager.shared
    
    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .updating($pinchMagnification, body: { value, state, _ in
                state = value
            })
            .onChanged { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = true
                    zIndexMap[.swift] = nextZIndex
                    nextZIndex += 1
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0)) {
                    glareTrigger = true
                }
            }
            .onEnded { value in
                self.currentMagnification *= value
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = false
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0).delay(0.1)) {
                    glareTrigger = false
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
                    zIndexMap[.swift] = nextZIndex
                    nextZIndex += 1
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0)) {
                    glareTrigger = true
                }
            }
            .onEnded { _ in
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
            .updating($twistAngle, body: { value, state, _ in
                state = value
            })
            .onChanged { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = true
                    zIndexMap[.swift] = nextZIndex
                    nextZIndex += 1
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0)) {
                    glareTrigger = true
                }
            }
            .onEnded { value in
                self.currentRotation += value
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
                    dragTrigger = false
                }
                withAnimation(.spring(response: 0.9, dampingFraction: 0.9, blendDuration: 0).delay(0.1)) {
                    glareTrigger = false
                }
            }
        
        let doubleTap3D = TapGesture(count: 2)
            .onEnded { _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                    if activeSticker == .swift {
                        activeSticker = nil
                    } else {
                        activeSticker = .swift
                    }
                }
            }
        
        let combinedGestures = magnificationGesture
            .simultaneously(with: dragGesture)
            .simultaneously(with: rotationGesture)
            .simultaneously(with: doubleTap3D)
        
        ZStack {
            MKSymbolShape(imageName: "swiftSticker")
                .stroke(
                    activeSticker == .swift ? .white.opacity(0.4) : .white,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round, // This makes the stroke ends rounded
                        lineJoin: .round // This makes the stroke joins rounded
                    )
                )
                .frame(width: 92, height: 82)
                .rotation3DEffect(activeSticker == .swift ? .degrees(zAxisSliderValue) : .zero, axis: (x: 0, y: 0, z: 1))
                .rotation3DEffect(activeSticker == .swift ? .degrees(xAxisSliderValue) : .zero, axis: (x: 1, y: 0, z: 0))
                .shadow(color: Color.black.opacity(dragTrigger ? 0.35 : 0.25), radius: dragTrigger ? 25 : 4, x: 0, y: dragTrigger ? 55 : 2)

            Image("swiftSticker")
                .resizable()
                .scaledToFill()
                .frame(width: 92, height: 82)
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/ .fill/*@END_MENU_TOKEN@*/)
                .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 0)
                .rotation3DEffect(activeSticker == .swift ? .degrees(zAxisSliderValue) : .zero, axis: (x: 0, y: 0, z: 1))
                .rotation3DEffect(activeSticker == .swift ? .degrees(xAxisSliderValue) : .zero, axis: (x: 1, y: 0, z: 0))
                .offset(x: 0, y: activeSticker == .swift ? -1 * offsetSliderValue : 0)
                
//            Image("swiftStickerOutline")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 100, height: 90, alignment: .center)
//                .offset(x: 0, y: 0)
//                .foregroundColor(.black.opacity(0.15))
//                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                .rotation3DEffect(activeSticker == .swift ? .degrees(zAxisSliderValue) : .zero, axis: (x: 0, y: 0, z: 1))
//                .rotation3DEffect(activeSticker == .swift ? .degrees(xAxisSliderValue) : .zero, axis: (x: 1, y: 0, z: 0))
//                .offset(x: 0, y: activeSticker == .swift ? -2*offsetSliderValue : 0)
//
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(
//                        stops: [
//                            Gradient.Stop(color: Color(hex: "#FE7F7F").opacity(0.9), location: 0),
//                            Gradient.Stop(color: Color(hex: "#FE91E4").opacity(0.9), location: 0.1),
//                            Gradient.Stop(color: Color(hex: "#FFE6AA").opacity(0.95), location: 0.25),
//                            Gradient.Stop(color: Color(hex: "#FFFFF2").opacity(1), location: 0.5),
//                            Gradient.Stop(color: Color(hex: "#A5D2FF").opacity(0.95), location: 0.75),
//                            Gradient.Stop(color: Color(hex: "#7E70FF").opacity(0.9), location: 0.9),
//                            Gradient.Stop(color: Color(hex: "#C033FF").opacity(0.9), location: 1)
//                        ]
//                    ),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .opacity(1)
//                .blur(radius: 20.0)
//                .frame(width: 120, height: 110)
//                .offset(x: CGFloat(0), y:CGFloat(MotionManager.shared.relativePitch * 400)+70)
//                .rotationEffect(.degrees(MotionManager.shared.relativeRoll * 60))
//                .overlay {
//                    Image("WhiteNoiseLayer")
//                        .resizable()
//                        .scaledToFill()
//                        .opacity(0.7 - abs(MotionManager.shared.relativePitch * 1))
//                        .blendMode(.plusLighter)
//                }
//                .mask {
//                    Image("swiftStickerOutline")
//                        .resizable()
//                        .scaledToFill()
//                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                        .frame(width: 100, height: 90, alignment: .center)
//                        .offset(x: 0, y: 0)
//                }
//                .rotation3DEffect(activeSticker == .swift ? .degrees(zAxisSliderValue) : .zero, axis: (x: 0, y: 0, z: 1))
//                .rotation3DEffect(activeSticker == .swift ? .degrees(xAxisSliderValue) : .zero, axis: (x: 1, y: 0, z: 0))
//                .offset(x: 0, y: activeSticker == .swift ? -3*offsetSliderValue : 0)
//
//            Image("swiftSticker")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 91, height: 81)
//                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                .opacity(0.25)
//                .rotation3DEffect(activeSticker == .swift ? .degrees(zAxisSliderValue) : .zero, axis: (x: 0, y: 0, z: 1))
//                .rotation3DEffect(activeSticker == .swift ? .degrees(xAxisSliderValue) : .zero, axis: (x: 1, y: 0, z: 0))
//                .offset(x: 0, y: activeSticker == .swift ? -4*offsetSliderValue : 0)
//
//            Image("NoiseLayer")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 120, height: 110, alignment: .center)
//                .offset(x: 10, y: -2)
//                .opacity(0.05)
//                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                .mask {
//                    Image("swiftStickerOutline")
//                        .resizable()
//                        .scaledToFill()
//                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                        .frame(width: 100, height: 90, alignment: .center)
//                        .offset(x: 0, y: 0)
//                }
//                .rotation3DEffect(activeSticker == .swift ? .degrees(zAxisSliderValue) : .zero, axis: (x: 0, y: 0, z: 1))
//                .rotation3DEffect(activeSticker == .swift ? .degrees(xAxisSliderValue) : .zero, axis: (x: 1, y: 0, z: 0))
//                .offset(x: 0, y: activeSticker == .swift ? -5*offsetSliderValue : 0)
//
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(
//                        stops: [
//                            Gradient.Stop(color: Color(hex: "#000000").opacity(0.0), location: 0),
//                            Gradient.Stop(color: Color(hex: "#000000").opacity(0.0), location: 0.2),
//                            Gradient.Stop(color: Color(hex: "#000000").opacity(0.1), location: 0.3),
//                            Gradient.Stop(color: Color(hex: "#000000").opacity(0.4), location: 0.5),
//                            Gradient.Stop(color: Color(hex: "#000000").opacity(0.1), location: 0.7),
//                            Gradient.Stop(color: Color(hex: "#000000").opacity(0.0), location: 0.8),
//                            Gradient.Stop(color: Color(hex: "#000000").opacity(0.0), location: 1)
//                        ]
//                    ),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .frame(width: 110, height: 90)
//                .blur(radius: 10.0)
//                .offset(x: 0, y: glareTrigger ? 90 : -90)
//                .opacity(activeSticker == .swift ? 0 : 1)
//                .mask {
//                    Image("swiftStickerOutline")
//                        .resizable()
//                        .scaledToFill()
//                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                        .frame(width: 100, height: 90, alignment: .center)
//                        .offset(x: 0, y: 0)
//                }
//                .allowsHitTesting(false)
        }
        .scaleEffect((currentMagnification * pinchMagnification) * (dragTrigger ? 1.2 : 1.0))
        .animation(.spring(), value: MotionManager.shared.relativePitch)
        .rotationEffect(currentRotation + twistAngle, anchor: .center)
        .offset(offset)
        .gesture(combinedGestures)
        .sensoryFeedback(.impact, trigger: dragTrigger)
        .onChange(of: resetStickerOffset) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0)) {
                if resetStickerOffset {
                    offset = .zero
                    initialLocation = .zero
                    previousOffset = .zero
                    currentMagnification = 1
                    currentRotation = Angle.zero
                }
            }
        }
        .onChange(of: activeSticker) {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.86, blendDuration: 0)) {
                if activeSticker == .swift {
                    previousRotation = currentRotation + twistAngle
                    currentRotation = .zero
                } else {
                    currentRotation = previousRotation
                }
            }
        }
    }
}
