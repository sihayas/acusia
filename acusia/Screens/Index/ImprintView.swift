//
//  ImprintView.swift
//  acusia
//
//  Created by decoherence on 9/13/24.
//
import BigUIPaging
import SwiftUI
import Wave

struct ImprintView: View {
    // Card Deck
    @State private var selection: Int = 2
    @Environment(\.navigatePageView) private var navigate
    @Environment(\.canNavigatePageView) private var canNavigate

    // Wave
    let offsetAnimator = SpringAnimator<CGPoint>(spring: .defaultInteractive, value: .zero)
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
    
    // Parameters
    @Binding var result: SearchResult

    var body: some View {
        VStack {
            Spacer()
            // Card stack
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        GeometryReader { _ in
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
                                        )
                                            
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(result.artistName)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                Text(result.title)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                    .lineLimit(1)
                                            }
                                                
                                            Spacer()
                                        }
                                        .padding(20)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    }
                                }
                                .frame(height: 280)
                        }
                    } else {
                        GeometryReader { geo in
                            let mainFrame = geo.frame(in: .global)
                            let smallRectanglePosition = CGPoint(x: mainFrame.maxX - 28 - 20, y: mainFrame.maxY - 28 - 20)
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                                .background(.clear)
                                .overlay(alignment: .bottom) {
                                    ZStack(alignment: .bottomTrailing) {
                                        AsyncImage(url: result.artwork?.url(width: 1000, height: 1000)) { image in
                                            image
                                                .resizable()
                                        } placeholder: {
                                            Rectangle()
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                        .aspectRatio(contentMode: .fit)
                                        
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: 28, height: 28)
                                            .position(smallRectanglePosition) // Using calculated position
                                            .onAppear {
                                                // Capture the position of the target for the shape
                                                shapeTargetPosition = smallRectanglePosition
                                            }
                                            .padding(20)
                                    }
                                    .opacity(0.1)
                                }
                                .onAppear {
                                    // Capture the bottom-right position for the ripple effect
                                    let bottomTrailing = CGPoint(x: mainFrame.maxX, y: mainFrame.maxY)
                                    origin = bottomTrailing
                                }
                                .modifier(RippleEffect(at: origin, trigger: rippleTrigger, velocity: velocity))
                        }
                        .frame(height: 280)
                    }
                }
            }
            .pageViewStyle(.customCardDeck)
            .pageViewCardShadow(.visible)
            .frame(width: 204, height: 280)
                
            // MARK: - Imprint Ball

            Spacer()
            ZStack {
                HStack(spacing: 32) {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Spacer()
                        .frame(width: 80, height: 80) // Spacer between the texts

                    Image(systemName: "heart.fill")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                }
                .frame(maxWidth: .infinity)
                
                ZStack {
                    GeometryReader { geo in
                        MorphableShape(controlPoints: self.controlPoints)
                            .fill(morphShape ? .white : .black)
                            .frame(width: morphShape ? 28 : 80, height: morphShape ? 28 : 80)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .opacity(showKeyframeShape.contains(true) ? 0 : 1)
                            .onAppear {
                                // Capture the initial position of the blue rectangle
                                shapeInitialPosition = CGPoint(x: geo.frame(in: .global).minX, y: geo.frame(in: .global).minY)
                            }
                        
                        // Quickly transition to a keyframe heart.
                        Group {
                            if showKeyframeShape[0] {
                                HeartbreakLeftPath()
                                    .stroke(.white, lineWidth: 1)
                                    .fill(.white)
                                    .frame(width: 28, height: 28)
                                    .applyHeartbreakLeftAnimator(triggerKeyframe: keyframeTrigger)
                                
                                HeartbreakRightPath()
                                    .stroke(.white, lineWidth: 1)
                                    .fill(.white)
                                    .frame(width: 28, height: 28)
                                    .applyHeartbreakRightAnimator(triggerKeyframe: keyframeTrigger)
                            } else if showKeyframeShape[1] {
                                HeartPath()
                                    .stroke(.white, lineWidth: 1)
                                    .fill(.white)
                                    .frame(width: 28, height: 28)
                                    .applyHeartbeatAnimator(triggerKeyframe: keyframeTrigger)
                            }
                        }
                        .onAppear {
                            // Trigger the ripple effect immediately
                            rippleTrigger += 1
                            
                            // Trigger the keyframe animation after a 0.4-second delay
                            keyframeTrigger += 1
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
                            print("Animation finished at value: \(finalValue)")
                            
                        case .retargeted(let from, let to):
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
            
            Spacer()
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
