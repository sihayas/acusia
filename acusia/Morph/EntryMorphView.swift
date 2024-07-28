import SwiftUI
import CoreHaptics

struct EntryMorphView: View {
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
    let dragThreshold: CGFloat = 1.2
    @State private var engine: CHHapticEngine?
    
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
                                    .fill(Color.black)
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
                    .scaleEffect(scale)
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
            Blob(size: size, tag: 0,
                 offsetX: { baseOffset[0] ? size * 0.5 : 0 },
                 offsetY: { baseOffset[0] ? -size : 0 })
                .scaleEffect(dragScale[0])
            
            Blob(size: size, tag: 1,
                 offsetX: { baseOffset[1] ? -size * 0.5 : 0 },
                 offsetY: { 0 })
            .zIndex(100)
            .scaleEffect(dragScale[1])

            Blob(size: size, tag: 2,
                 offsetX: { baseOffset[2] ? size * 0.5 : 0 },
                 offsetY: { baseOffset[2] ? size : 0 })
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
    func Blob(
        size: CGFloat,
        tag: Int,
        offsetX: @escaping() -> CGFloat,
        offsetY: @escaping() -> CGFloat
    ) -> some View {
        Circle()
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .contentShape(Circle())
            .offset(x: offsetX(), y: offsetY())
            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
            .tag(tag)
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
    
    func updateDragScales(dragPoint: CGPoint, in geometry: GeometryProxy) {
        let blobPositions = [
            CGPoint(x: tapLocation.x + 40, y: tapLocation.y - 80), // Top left
            CGPoint(x: tapLocation.x - 40, y: tapLocation.y),      // Right
            CGPoint(x: tapLocation.x + 40, y: tapLocation.y + 80)  // Bottom left
        ]
        
        for (index, position) in blobPositions.enumerated() {
            let distance = sqrt(pow(dragPoint.x - position.x, 2) + pow(dragPoint.y - position.y, 2))
            let maxDistance: CGFloat = 100 // Adjust this value to change the range of influence
            let scaleFactor = max(0, (maxDistance - distance) / maxDistance)
            
            withAnimation(.spring()) {
                dragScale[index] = 1 + scaleFactor * 0.5 // Adjust 0.5 to change the maximum scale
            }
        }
    }
    
    func resetDragScales() {
        withAnimation(.spring()) {
            dragScale = Array(repeating: 1, count: 3)
        }
    }
}

extension EntryMorphView {
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

struct GenericView_Previews: PreviewProvider {
    static var previews: some View {
        EntryMorphView()
    }
}
