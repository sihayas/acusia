//
//  AvatarMorphView.swift
//  acusia
//
//  Created by decoherence on 7/2/24.
//

import SwiftUI
import CoreHaptics

struct AvatarMorphView: View {
    @State private var isExpanded: Bool = false
    @State private var isVisible: Bool = false
    @State private var tapLocation: CGPoint = .zero
    
    @State private var radius: CGFloat = 10
    @State private var animatedRadius: CGFloat = 10
    @State private var scale: CGFloat = 0.01
    @State private var baseOffset: [Bool] = Array(repeating: false, count: 3)
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGSize = .zero
    
    @State private var dragScale: [CGFloat] = Array(repeating: 1, count: 3)
    @State private var engine: CHHapticEngine?
    let dragThreshold: CGFloat = 1.2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if !isVisible {
                                    tapLocation = value.location
                                    appearAndExpand(at: value.location)
                                } else {
                                    updateDragScales(dragPoint: value.location, in: geometry)
                                }
                                isDragging = true
                            }
                            .onEnded { _ in
                                isDragging = false
                                resetDragScales()
                                collapseAndDisappear()
                            }
                    )
                
                VStack {
                    let circleSize = 80.0
                    ZStack {
                        ShapeMorphing(color: .black)
                            .background {
                                Rectangle()
                                    .fill(Color(UIColor.systemGray6))
                                    .mask {
                                        Canvas { ctx, size in
                                            ctx.addFilter(.alphaThreshold(min: 0.5))
                                            ctx.addFilter(.blur(radius: animatedRadius))
                                            
                                            ctx.drawLayer { ctx1 in
                                                for index in 0 ..< 3 {
                                                    if let resolvedShareButton = ctx.resolveSymbol(id: index) {
                                                        ctx1.draw(resolvedShareButton, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                                    }
                                                }
                                            }
                                        } symbols: {
                                            GroupedButtons(size: circleSize, fillColor: true)
                                        }
                                    }
                            }
                            .allowsHitTesting(false)
                        GroupedButtons(size: circleSize, fillColor: false)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
//                    .scaleEffect(scale)
                    .opacity(isVisible ? 1 : 0)
                }
                .position(isVisible ? tapLocation : CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    func GroupedButtons(size: CGFloat, fillColor: Bool = true) -> some View {
        Group {
            RightArc(size: size, tag: 0,
                 offsetX: { baseOffset[0] ? 0 : 0 },
                 offsetY: { baseOffset[0] ? 0 : 0 })
            .scaleEffect(dragScale[0])
            
            BottomArc(size: size, tag: 1,
                 offsetX: { baseOffset[1] ? 0 : 0 },
                 offsetY: { baseOffset[1] ? 0 : 0 })
            .scaleEffect(dragScale[1])
            
            LeftArc(size: size, tag: 2,
                 offsetX: { baseOffset[2] ? 0 : 0 },
                 offsetY: { baseOffset[2] ? 0 : 0 })
            .scaleEffect(dragScale[2])
        }
        .foregroundColor(fillColor ? .black : .clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animationProgress(endValue: radius) { value in
            animatedRadius = value
            
            if value >= 12 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    radius = 10
                }
            }
        }
    }

    @ViewBuilder
    func RightArc(
        size: CGFloat,
        tag: Int,
        offsetX: @escaping () -> CGFloat,
        offsetY: @escaping () -> CGFloat
    ) -> some View {
        Path { path in
            path.addArc(center: CGPoint(x: size/2, y: size/2),
                        radius: size/2,
                        startAngle: .degrees(285),
                        endAngle: .degrees(45),
                        clockwise: false)
        }
        .stroke(.red.opacity(0.5), style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
        .offset(x: offsetX(), y: offsetY())
        .tag(tag)
    }

    @ViewBuilder
    func BottomArc(
        size: CGFloat,
        tag: Int,
        offsetX: @escaping () -> CGFloat,
        offsetY: @escaping () -> CGFloat
    ) -> some View {
        Path { path in
            path.addArc(center: CGPoint(x: size/2, y: size/2),
                        radius: size/2,
                        startAngle: .degrees(45),
                        endAngle: .degrees(165),
                        clockwise: false)
        }
        .stroke(.blue.opacity(0.5), style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
        .offset(x: offsetX(), y: offsetY())
        .tag(tag)
    }

    @ViewBuilder
    func LeftArc(
        size: CGFloat,
        tag: Int,
        offsetX: @escaping () -> CGFloat,
        offsetY: @escaping () -> CGFloat
    ) -> some View {
        Path { path in
            path.addArc(center: CGPoint(x: size/2, y: size/2),
                        radius: size/2,
                        startAngle: .degrees(165),
                        endAngle: .degrees(285),
                        clockwise: false)
        }
        .stroke(.green.opacity(0.5), style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
        .offset(x: offsetX(), y: offsetY())
        .tag(tag)
    }
}

// MARK: Dragging
extension AvatarMorphView {
    func updateDragScales(dragPoint: CGPoint, in geometry: GeometryProxy) {
        let center = tapLocation
        let arcRanges = [
            (start: 285.0, end: 45.0),  // Right arc (Red)
            (start: 45.0, end: 165.0),  // Bottom arc (Blue)
            (start: 165.0, end: 285.0)  // Left arc (Green)
        ]

        for (index, range) in arcRanges.enumerated() {
            let dragAngle = atan2(dragPoint.y - center.y, dragPoint.x - center.x) * 180 / .pi
            let normalizedDragAngle = (dragAngle + 360).truncatingRemainder(dividingBy: 360)
            
            let start = range.start
            let end = range.end
            let arcLength = (end - start + 360).truncatingRemainder(dividingBy: 360)
            
            var distanceFromStart = (normalizedDragAngle - start + 360).truncatingRemainder(dividingBy: 360)
            if distanceFromStart > arcLength {
                distanceFromStart = arcLength
            }
            
            let scaleFactor = min(max(0, distanceFromStart / arcLength), 1)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)) {
                dragScale[index] = 1 + scaleFactor * 0.3
            }
        }
    }
    
    func resetDragScales() {
        withAnimation(.spring()) {
            dragScale = Array(repeating: 1, count: 3)
        }
    }
    
    func playHapticFeedback(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: 0)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic feedback: \(error.localizedDescription)")
        }
    }
}

// MARK: Expansion
extension AvatarMorphView {
    func toggleExpand() {
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.4)) {
            isExpanded.toggle()
            scale = isExpanded ? 0.75 : 1
        }
        
        withAnimation(.easeInOut(duration: 0.4)) {
            radius = 20
        }
        
        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.8)) {
            for index in baseOffset.indices {
                baseOffset[index] = isExpanded
            }
        }
    }
    
    func appearAndExpand(at location: CGPoint) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
            isVisible = true
            scale = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            toggleExpand()
        }
        playHapticFeedback(intensity: 0.3, sharpness: 0.9)
    }
    
    func collapseAndDisappear() {
        toggleExpand()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                isVisible = false
                scale = 0.01
            }
        }
    }
    
}

// preview
struct AvatarMorphView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarMorphView()
            .background(.black)
    }
}
