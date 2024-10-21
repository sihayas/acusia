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
    var result: SearchResult

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
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
                        
                            // Second GeometryReader inside overlay to get frame of smaller rectangle
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 28, height: 28)
                                .padding(20)
                        }
                    }
                    .modifier(RippleEffect(at: shapeTargetPosition, trigger: rippleTrigger, velocity: velocity))
                    .onAppear {
                        shapeTargetPosition = CGPoint(
                            x: geometry.frame(in: .global).maxX - 54 - 20, // 20 padding from the right
                            y: geometry.frame(in: .global).maxY - 54 - 20 // 20 padding from the bottom
                        )
                    }
            }
            .frame(width: 336, height: 336)
                
            // MARK: - Imprint Ball

            Spacer()
            ZStack {
                HStack(spacing: 32) {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Spacer between the texts
                    Spacer()
                        .frame(width: 80, height: 80)

                    // Align to the left
                    Image(systemName: "heart.fill")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                
                ZStack {
                    GeometryReader { geo in
                        MorphableShape(controlPoints: self.controlPoints)
                            .fill(morphShape ? .white : .black)
                            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 15)
                            .opacity(showKeyframeShape.contains(true) ? 0 : 1)
                            .onAppear {
                                // Capture the initial position of the shape
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
                    .frame(width: morphShape ? 28 : 80, height: morphShape ? 28 : 80)
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
                                print("Target Offset: \(targetOffset)")
                                
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
