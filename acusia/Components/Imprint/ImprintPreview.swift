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
    ImprintPreview()
}

struct ImprintPreview: View {
    // Card Deck
    @State private var selection: Int = 1

    // Wave
    let offsetAnimator = SpringAnimator<CGPoint>(spring: .defaultInteractive)
    let interactiveSpring = Spring(dampingRatio: 0.8, response: 0.26)
    let animatedSpring = Spring(dampingRatio: 0.72, response: 0.7)
    @State var shapeOffset: CGPoint = .zero
    @State var shapeTargetPosition: CGPoint = .zero
    @State var shapeInitialPosition: CGPoint = .zero

    // Morph
    @State var controlPoints: AnimatableVector = circleControlPoints
    @State var morphShape = false

    // Keyframe Animations
    @State var showKeyframeShape = [false, false] // Left, Right
    @State var keyframeTrigger: Int = 0

    // Ripple Shader
    @State var rippleTrigger: Int = 0
    @State var origin: CGPoint = .zero
    @State private var velocity: CGFloat = 1.0

    var body: some View {
        let imageUrl = "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/ab/9d/c9/ab9dc97e-4147-e677-c7f3-05afd5562c23/cover.jpg/600x600bb.jpg"
        let name = "megacity1000"
        let artistName = "1tbsp"

        VStack {
            // Card stack
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(Color(UIColor.systemGray6))
                                .overlay {
                                    ZStack(alignment: .bottomTrailing) {
                                        VStack {
                                            Text("")
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
                                            
                                            // Reserve space for shape to animate to.
                                            GeometryReader { geo in
                                                Rectangle()
                                                    .fill(.clear)
                                                    .frame(width: 28, height: 28)
                                                    .onAppear {
                                                        // Capture the position of the target for the shape
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
                                .modifier(RippleEffect(at: origin, trigger: rippleTrigger, velocity: velocity))
                                .onAppear {
                                    // Capture the bottom-right position for the ripple effect
                                    let frame = geo.frame(in: .global)
                                    let bottomTrailing = CGPoint(x: frame.maxX, y: frame.maxY)
                                    origin = bottomTrailing
                                }
                        }
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

            Spacer()
                .frame(width: 32, height: 124)

            ZStack {
                GeometryReader { geo in
                    MorphableShape(controlPoints: self.controlPoints)
                        .fill(morphShape ? .white : .secondary)
                        .frame(width: morphShape ? 28 : 80, height: morphShape ? 28 : 80)
                        .onAppear {
                            // Capture the initial position of the blue rectangle
                            shapeInitialPosition = CGPoint(x: geo.frame(in: .global).minX, y: geo.frame(in: .global).minY)
                        }
                        .opacity(showKeyframeShape.contains(true) ? 0 : 1)

                    // Quickly transition to a keyframe heart.
                    Group {
                        if showKeyframeShape[0] {
                            HeartbreakLeftPath()
                                .stroke(.white, lineWidth: 1)
                                .fill(.white)
                                .frame(width: 28, height: 28)
                                .applyHeartbreakLeftAnimator(triggerKeyframe: keyframeTrigger)
                                .opacity(1)

                            HeartbreakRightPath()
                                .stroke(.white, lineWidth: 1)
                                .fill(.white)
                                .frame(width: 28, height: 28)
                                .applyHeartbreakRightAnimator(triggerKeyframe: keyframeTrigger)
                                .opacity(1)
                        } else if showKeyframeShape[1] {
                            HeartPath()
                                .stroke(.white, lineWidth: 1)
                                .fill(.white)
                                .frame(width: 28, height: 28)
                                .applyHeartbeatAnimator(triggerKeyframe: keyframeTrigger)
                                .opacity(1)
                        }
                    }
                    .onAppear {
                        keyframeTrigger += 1
                        rippleTrigger += 1
                    }
                    .onTapGesture {
                        // Reset the animator to the original position
                        offsetAnimator.spring = interactiveSpring
                        offsetAnimator.target = .zero

                        // Use animated mode to animate the transition.
                        offsetAnimator.mode = .animated
                        offsetAnimator.start()

                        withAnimation(.easeOut(duration: 0.3)) {
                            morphShape = false
                            self.controlPoints = circleControlPoints
                            showKeyframeShape = [false, false]
                        }
                    }
                }
                .frame(width: 80, height: 80)
            }
            .offset(x: shapeOffset.x, y: shapeOffset.y)
            .onAppear {
                // Initialize wave animator
                offsetAnimator.value = .zero

                // The offset animator's callback will update the `offset` state variable.
                offsetAnimator.valueChanged = { newValue in
                    shapeOffset = newValue
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

                        // Pass to the Ripple shader for impact
                        self.velocity = velocityMagnitude / 1000

                        // Thresholds for a quick swipe
                        let minimumVelocity: CGFloat = 750 // points per second

                        if velocityMagnitude >= minimumVelocity {
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
                                // Shrink the circle
                                morphShape.toggle()

                                // Morph circle into a heart
                                self.controlPoints = heartControlPoints

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    if velocityX < 0 {
                                        // Left swipe
                                        showKeyframeShape[0] = true
                                    } else if velocityX > 0 {
                                        // Right swipe
                                        showKeyframeShape[1] = true
                                    }
                                }
                            }
                        } else {
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
