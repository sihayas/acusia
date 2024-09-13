import SwiftUI

struct AnimationValues {
    var scale = 1.0
    var verticalStretch = 1.0
    var horizontalStretch = 1.0
    var verticalTranslation = 0.0
    var horizontalTranslation = 0.0
    var angle = Angle.zero
    var horizontalSpin = Angle.zero
}


#Preview {
    HeartbreakReactionView()
}

struct HeartReactionView: View {
    @State private var isAnimating = false

    var body: some View {
        // Heart emoji
        HeartPath()
            .stroke(.white, lineWidth: 1)
            .fill(.white)
            .frame(width: 64, height: 58)
            .keyframeAnimator(initialValue: AnimationValues()) { content, value in
                content
                    .foregroundStyle(.white)
                    .rotation3DEffect(value.horizontalSpin, axis: (x: 0, y: 1, z: 0))
                    .rotationEffect(value.angle)
                    .scaleEffect(value.scale)
                    .scaleEffect(y: value.verticalStretch)
                    .scaleEffect(x: value.horizontalStretch)
                    .offset(y: value.verticalTranslation)
                    .offset(x: value.horizontalTranslation)
            } keyframes: { _ in
                KeyframeTrack(\.horizontalSpin) {
                    // Start with no spin
                    CubicKeyframe(.degrees(0), duration: 0.1) // No spin before translation starts
                    // Spin inward during upward translation
                    CubicKeyframe(.degrees(360), duration: 0.5)
                }

                // Keyframes for vertical stretch (squish and unsquish)
                KeyframeTrack(\.verticalStretch) {
                    CubicKeyframe(1.0, duration: 0.1)
                    CubicKeyframe(0.3, duration: 0.15)
                    CubicKeyframe(1.5, duration: 0.1)
                    CubicKeyframe(1.05, duration: 0.15)
                    CubicKeyframe(1.0, duration: 0.88)
                    CubicKeyframe(0.8, duration: 0.1)
                    CubicKeyframe(1.04, duration: 0.4)
                    CubicKeyframe(1.0, duration: 0.22)
                }

                // Keyframes for horizontal stretch (squish and unsquish)
                KeyframeTrack(\.horizontalStretch) {
                    CubicKeyframe(1.0, duration: 0.1)
                    CubicKeyframe(1.3, duration: 0.15)
                    CubicKeyframe(0.5, duration: 0.1)
                    CubicKeyframe(1.05, duration: 0.15)
                    CubicKeyframe(1.0, duration: 0.88)
                    CubicKeyframe(1.2, duration: 0.1)
                    CubicKeyframe(0.98, duration: 0.4)
                    CubicKeyframe(1.0, duration: 0.22)
                }

                // Keyframes for scaling (adjusted for longer, more noticeable heartbeat effect)
                KeyframeTrack(\.scale) {
                    // Start at normal size
                    LinearKeyframe(1.0, duration: 0.5) // Delay the heartbeat start
                    // Exaggerated, longer first beat "du"
                    SpringKeyframe(1.8, duration: 0.15, spring: .bouncy)
                    // Deep, dramatic dip down
                    SpringKeyframe(0.6, duration: 0.15, spring: .bouncy)
                    // Extremely exaggerated, powerful second beat "dun"
                    SpringKeyframe(3.5, duration: 0.18, spring: .bouncy)
                    // Sharp snap back to normal with an overshoot for extra bounce
                    SpringKeyframe(0.9, duration: 0.15, spring: .bouncy)
                    SpringKeyframe(1.2, duration: 0.15, spring: .bouncy)
                    // Final return to normal size
                    LinearKeyframe(1.0, duration: 0.2)
                }

                // Keyframes for vertical translation (bouncing up and down)
                KeyframeTrack(\.verticalTranslation) {
                    LinearKeyframe(0.0, duration: 0.1)
                    SpringKeyframe(90.0, duration: 0.15, spring: .bouncy)
                    SpringKeyframe(-90.0, duration: 1.0, spring: .bouncy)
                    SpringKeyframe(0.0, spring: .bouncy)
                }
            }
    }
}

struct HeartbreakReactionView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            HeartbreakLeftPath()
                .stroke(.white, lineWidth: 1)
                .fill(.white)
                .frame(width: 64, height: 58)
                .keyframeAnimator(initialValue: AnimationValues()) { content, value in
                    content
                        .foregroundStyle(.white)
                        .rotation3DEffect(value.horizontalSpin, axis: (x: 0, y: 1, z: 0))
                        .rotationEffect(value.angle)
                        .scaleEffect(value.scale)
                        .scaleEffect(y: value.verticalStretch)
                        .scaleEffect(x: value.horizontalStretch)
                        .offset(y: value.verticalTranslation)
                        .offset(x: value.horizontalTranslation)
                } keyframes: { _ in
                    KeyframeTrack(\.horizontalSpin) {
                        // Start with no spin
                        CubicKeyframe(.degrees(0), duration: 0.1) // No spin before translation starts
                        // Spin inward during upward translation
                        CubicKeyframe(.degrees(-360), duration: 0.5)
                    }

                    KeyframeTrack(\.angle) {
                        CubicKeyframe(.zero, duration: 0.58)
                        CubicKeyframe(.degrees(16), duration: 0.125)
                        CubicKeyframe(.degrees(-16), duration: 0.125)
                        CubicKeyframe(.degrees(16), duration: 0.125)
                        CubicKeyframe(.zero, duration: 0.125)
                    }

                    // Keyframes for vertical stretch (squish and unsquish)
                    KeyframeTrack(\.verticalStretch) {
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(0.3, duration: 0.15) // Stretch horizontally as it squeezes down
                        CubicKeyframe(1.5, duration: 0.1) // Stretch vertically as it rises to the top
                        CubicKeyframe(1.0, duration: 0.15) // Right before it hits the top
                        CubicKeyframe(1.0, duration: 0.88) // Stretch out at the top
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(1.04, duration: 0.4) // Right before it hits the ground
                        CubicKeyframe(1.0, duration: 0.22) // Once it hits the ground
                    }

                    // Keyframes for horizontal stretch (squish and unsquish)
                    KeyframeTrack(\.horizontalStretch) {
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(1.3, duration: 0.15)
                        CubicKeyframe(0.5, duration: 0.1)
                        CubicKeyframe(1.25, duration: 0.15)
                        CubicKeyframe(1.0, duration: 0.88)
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(0.98, duration: 0.4)
                        CubicKeyframe(1.0, duration: 0.22)
                    }

                    // Keyframes for vertical translation (bouncing up and down)
                    KeyframeTrack(\.verticalTranslation) {
                        LinearKeyframe(0.0, duration: 0.1)
                        SpringKeyframe(90.0, duration: 0.15, spring: .bouncy)
                        SpringKeyframe(-90.0, duration: 1.0, spring: .bouncy)
                        SpringKeyframe(0.0, spring: .bouncy)
                    }
                    
                    KeyframeTrack(\.horizontalTranslation) {
                        LinearKeyframe(0.0, duration: 0.75)
                        SpringKeyframe(-4.0, duration: 1.0, spring: .bouncy)
                        SpringKeyframe(0.0, spring: .bouncy)
                    }
                }
            
            HeartbreakRightPath()
                .stroke(.white, lineWidth: 1)
                .fill(.white)
                .frame(width: 64, height: 58)
                .keyframeAnimator(initialValue: AnimationValues()) { content, value in
                    content
                        .foregroundStyle(.white)
                        .rotation3DEffect(value.horizontalSpin, axis: (x: 0, y: 1, z: 0))
                        .rotationEffect(value.angle)
                        .scaleEffect(value.scale)
                        .scaleEffect(y: value.verticalStretch)
                        .scaleEffect(x: value.horizontalStretch)
                        .offset(y: value.verticalTranslation)
                        .offset(x: value.horizontalTranslation)
                } keyframes: { _ in
                    KeyframeTrack(\.horizontalSpin) {
                        // Start with no spin
                        CubicKeyframe(.degrees(0), duration: 0.1) // No spin before translation starts
                        // Spin inward during upward translation
                        CubicKeyframe(.degrees(-360), duration: 0.5)
                    }

                    KeyframeTrack(\.angle) {
                        CubicKeyframe(.zero, duration: 0.58)
                        CubicKeyframe(.degrees(16), duration: 0.125)
                        CubicKeyframe(.degrees(-16), duration: 0.125)
                        CubicKeyframe(.degrees(16), duration: 0.125)
                        CubicKeyframe(.zero, duration: 0.125)
                    }

                    // Keyframes for vertical stretch (squish and unsquish)
                    KeyframeTrack(\.verticalStretch) {
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(0.3, duration: 0.15) // Stretch horizontally as it squeezes down
                        CubicKeyframe(1.5, duration: 0.1) // Stretch vertically as it rises to the top
                        CubicKeyframe(1.0, duration: 0.15) // Right before it hits the top
                        CubicKeyframe(1.0, duration: 0.88) // Stretch out at the top
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(1.04, duration: 0.4) // Right before it hits the ground
                        CubicKeyframe(1.0, duration: 0.22) // Once it hits the ground
                    }

                    // Keyframes for horizontal stretch (squish and unsquish)
                    KeyframeTrack(\.horizontalStretch) {
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(1.3, duration: 0.15)
                        CubicKeyframe(0.5, duration: 0.1)
                        CubicKeyframe(1.25, duration: 0.15)
                        CubicKeyframe(1.0, duration: 0.88)
                        CubicKeyframe(1.0, duration: 0.1)
                        CubicKeyframe(0.98, duration: 0.4)
                        CubicKeyframe(1.0, duration: 0.22)
                    }
                    
                    // Keyframes for vertical translation (bouncing up and down)
                    KeyframeTrack(\.verticalTranslation) {
                        LinearKeyframe(0.0, duration: 0.1)
                        SpringKeyframe(90.0, duration: 0.15, spring: .bouncy)
                        SpringKeyframe(-90.0, duration: 1.0, spring: .bouncy)
                        SpringKeyframe(0.0, spring: .bouncy)
                    }
                    
                    KeyframeTrack(\.horizontalTranslation) {
                        LinearKeyframe(0.0, duration: 0.75)
                        SpringKeyframe(4.0, duration: 1.0, spring: .bouncy)
                        SpringKeyframe(0.0, spring: .bouncy)
                    }
                    
                }
        }
        .frame(width: 64, height: 58)
    }
}
