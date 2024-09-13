//
//  Wave.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//
import BigUIPaging
import SwiftUI
import Wave

#Preview {
    SwiftUIView()
}

struct SwiftUIView: View {
    // Card Deck
    @State private var selection: Int = 1

    // Wave
    let offsetAnimator = SpringAnimator<CGPoint>(spring: .defaultInteractive)
    let interactiveSpring = Spring(dampingRatio: 0.8, response: 0.26)
    let animatedSpring = Spring(dampingRatio: 0.72, response: 0.7)
    @State var boxOffset: CGPoint = .zero
    @State var shapeTargetPosition: CGPoint = .zero
    @State var shapeInitialPosition: CGPoint = .zero

    // Morph
    @State var controlPoints: AnimatableVector = circleControlPoints
    @State var rating: Double = 0
    @State var animateMorph = false
    @State var triggerKeyframe = false

    var body: some View {
        let imageUrl = "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/26/24/07/2624075e-51b9-60a4-bc11-93bbdde0f36c/103097.jpg/600x600bb.jpg"
        let name = "Why Bonnie?"
        let artistName = "Wish on the Bone"
        let text = "‘Wish On The Bone’ is out now ⛓️‍💥🌱 I’m truly at a loss for words — so much love, change, & passion went into this album. My hope is that you can feel some of that love when listening to these songs & that it gives you strength to take on the day. Or at least, bop along🦋"

        VStack {
            // Card stack
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .foregroundStyle(.ultraThickMaterial)
                            .background(
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                } placeholder: {
                                    Rectangle()
                                }
                            )
                            .overlay {
                                ZStack(alignment: .bottomTrailing) {
                                    VStack {
                                        Text(text)
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .semibold))
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding([.horizontal, .top], 20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .mask(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .black, location: 0),
                                                .init(color: .black, location: 0.75),
                                                .init(color: .clear, location: 0.825)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .frame(height: .infinity)
                                    )

                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(artistName)
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                                .lineLimit(1)
                                            Text(name)
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        // Reserve space for mark to animate to.
                                        GeometryReader { geo in
                                            Rectangle()
                                                .fill(.clear)
                                                .frame(width: 28, height: 28)
                                                .onAppear {
                                                    // Capture the position of the red rectangle
                                                    shapeTargetPosition = CGPoint(x: geo.frame(in: .global).minX, y: geo.frame(in: .global).minY)
                                                }
                                        }
                                        .frame(width: 28, height: 28) // Limit GeometryReader size
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                }
                            }
                            .frame(height: 280)
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .background(.clear)
                            .overlay(alignment: .bottom) {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                } placeholder: {
                                    Rectangle()
                                }
                            }
                    }
                }
            }
            .pageViewStyle(.customCardDeck)
            .pageViewCardShadow(.visible)
            .frame(width: 204, height: 280)

            // Reset Button
            Button {
                offsetAnimator.spring = interactiveSpring
                offsetAnimator.target = .zero
                offsetAnimator.mode = .animated
                offsetAnimator.start()
                withAnimation(.easeOut(duration: 0.3)) {
                    animateMorph.toggle()
                    self.controlPoints = circleControlPoints
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.ultraThickMaterial)
                    .clipShape(Circle())
            }
            .frame(width: 32, height: 124)

            ZStack {
                GeometryReader { geo in
                    MorphableShape(controlPoints: self.controlPoints)
                        .fill(animateMorph ? .white : Color(UIColor.systemGray6))
                        .frame(width: animateMorph ? 28 : 64, height: animateMorph ? 28 : 64)
                        .keyframeAnimator(initialValue: AnimationValues(), trigger: triggerKeyframe) { content, value in
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
                                SpringKeyframe(15.0, duration: 0.15, spring: .bouncy)
                                SpringKeyframe(-90.0, duration: 1.0, spring: .bouncy)
                                SpringKeyframe(0.0, spring: .bouncy)
                            }
                        }
                        .onAppear {
                            // Capture the initial position of the blue rectangle
                            shapeInitialPosition = CGPoint(x: geo.frame(in: .global).minX, y: geo.frame(in: .global).minY)
                        }
                }
                .frame(width: 64, height: 64)
            }
            .offset(x: boxOffset.x, y: boxOffset.y)
            .onAppear {
                // Initialize wave animator
                offsetAnimator.value = .zero

                // The offset animator's callback will update the `offset` state variable.
                offsetAnimator.valueChanged = { newValue in
                    boxOffset = newValue
                }

                offsetAnimator.completion = { event in
                    switch event {
                    case .finished(let finalValue):
                        // Update blue rectangle position after the animation fully completes
                        print("Animation finished at value: \(finalValue)")

                    case .retargeted(let from, let to):
                        // Log the retarget event or handle if necessary
                        print("Animation retargeted from: \(from) to: \(to)")
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Update the animator's target to the new drag translation.
                        offsetAnimator.spring = interactiveSpring
                        offsetAnimator.target = CGPoint(x: value.translation.width, y: value.translation.height)
                        offsetAnimator.mode = .animated
                        offsetAnimator.start()
                    }
                    .onEnded { value in
                        // Use the instantaneous velocity provided by the gesture
                        let velocityX = value.velocity.width
                        let velocityY = value.velocity.height
                        let velocityMagnitude = hypot(velocityX, velocityY)

                        // Thresholds for a quick swipe
                        let minimumVelocity: CGFloat = 750 // points per second

                        if velocityMagnitude >= minimumVelocity {
                            print("Quick swipe detected!")

                            offsetAnimator.spring = animatedSpring
                            // Calculate the difference between the target and initial positions
                            let targetOffset = CGPoint(
                                x: shapeTargetPosition.x - shapeInitialPosition.x,
                                y: shapeTargetPosition.y - shapeInitialPosition.y
                            )

                            // Assign this offset as the new target for the animator
                            offsetAnimator.target = targetOffset

                            // Use animated mode to animate the transition.
                            offsetAnimator.mode = .animated

                            // Assign the gesture velocity to the animator to ensure a natural throw feel.
                            offsetAnimator.velocity = CGPoint(x: velocityX, y: velocityY)
                            offsetAnimator.start()

                            withAnimation(.easeOut(duration: 0.3)) {
                                animateMorph.toggle()
                                self.controlPoints = heartControlPoints
                                
                                // delay toggle keyframe
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    triggerKeyframe.toggle()
                                }
                            }
                        } else {
                            print("That was too slow!")

                            // Reset the animator to the original position
                            offsetAnimator.spring = interactiveSpring
                            offsetAnimator.target = .zero

                            // Use animated mode to animate the transition.
                            offsetAnimator.mode = .animated

                            // Assign the gesture velocity to the animator to ensure a natural throw feel.
                            offsetAnimator.velocity = CGPoint(x: velocityX, y: velocityY)

                            offsetAnimator.start()
                        }
                    }
            )
        }
    }

    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}
