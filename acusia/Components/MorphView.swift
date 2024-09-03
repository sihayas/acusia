//
//  MorphView.swift
//  acusia
//
//  Created by decoherence on 9/2/24.
//

import SwiftUI

extension Path {
    // return point at the curve
    func point(at offset: CGFloat) -> CGPoint {
        let limitedOffset = min(max(offset, 0), 1)
        guard limitedOffset > 0 else { return cgPath.currentPoint }
        return trimmedPath(from: 0, to: limitedOffset).cgPath.currentPoint
    }
    
    // return control points along the path
    func controlPoints(count: Int) -> AnimatableVector {
        var retPoints = [Double]()
        for index in 0..<count {
            let pathOffset = Double(index) / Double(count)
            let pathPoint = self.point(at: CGFloat(pathOffset))
            retPoints.append(Double(pathPoint.x))
            retPoints.append(Double(pathPoint.y))
        }
        return AnimatableVector(with: retPoints)
    }
}

struct AnimatableVector: VectorArithmetic {
    var values: [Double] // vector values
    
    init(count: Int = 1) {
        self.values = [Double](repeating: 0.0, count: count)
        self.magnitudeSquared = 0.0
    }
    
    init(with values: [Double]) {
        self.values = values
        self.magnitudeSquared = 0
        self.recomputeMagnitude()
    }
    
    func computeMagnitude() -> Double {
        // compute square magnitued of the vector
        // = sum of all squared values
        var sum = 0.0
        
        for index in 0..<self.values.count {
            sum += self.values[index]*self.values[index]
        }
        
        return Double(sum)
    }
    
    mutating func recomputeMagnitude() {
        self.magnitudeSquared = self.computeMagnitude()
    }
    
    // MARK: VectorArithmetic

    var magnitudeSquared: Double // squared magnitude of the vector
    
    mutating func scale(by rhs: Double) {
        // scale vector with a scalar
        // = each value is multiplied by rhs
        for index in 0..<self.values.count {
            self.values[index] *= rhs
        }
        self.magnitudeSquared = self.computeMagnitude()
    }
    
    // MARK: AdditiveArithmetic
    
    // zero is identity element for aditions
    // = all values are zero
    static var zero: AnimatableVector = .init()
    
    static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        var retValues = [Double]()
        
        for index in 0..<min(lhs.values.count, rhs.values.count) {
            retValues.append(lhs.values[index] + rhs.values[index])
        }
        
        return AnimatableVector(with: retValues)
    }
    
    static func += (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        for index in 0..<min(lhs.values.count, rhs.values.count) {
            lhs.values[index] += rhs.values[index]
        }
        lhs.recomputeMagnitude()
    }

    static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        var retValues = [Double]()
        
        for index in 0..<min(lhs.values.count, rhs.values.count) {
            retValues.append(lhs.values[index] - rhs.values[index])
        }
        
        return AnimatableVector(with: retValues)
    }
    
    static func -= (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        for index in 0..<min(lhs.values.count, rhs.values.count) {
            lhs.values[index] -= rhs.values[index]
        }
        lhs.recomputeMagnitude()
    }
}

struct MorphableShape: Shape {
    var controlPoints: AnimatableVector
    
    var animatableData: AnimatableVector {
        set { self.controlPoints = newValue }
        get { return self.controlPoints }
    }
    
    func point(x: Double, y: Double, rect: CGRect) -> CGPoint {
        // vector values are expected to by in the range of 0...1
        return CGPoint(x: Double(rect.width)*x, y: Double(rect.height)*y)
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            
            path.move(to: self.point(x: self.controlPoints.values[0],
                                     y: self.controlPoints.values[1], rect: rect))
            
            var i = 2
            while i < self.controlPoints.values.count - 1 {
                path.addLine(to: self.point(x: self.controlPoints.values[i],
                                            y: self.controlPoints.values[i + 1], rect: rect))
                i += 2
            }
            
            path.addLine(to: self.point(x: self.controlPoints.values[0],
                                        y: self.controlPoints.values[1], rect: rect))
        }
    }
}

func randomVector(count: Int) -> AnimatableVector {
    let randomValues = Array(1...count).map { _ in Double.random(in: 0...1.0) }
    return AnimatableVector(with: randomValues)
}

let circleControlPoints: AnimatableVector = Circle().path(in: CGRect(x: 0, y: 0, width: 1, height: 1))
    .controlPoints(count: 500)
let heartControlPoints: AnimatableVector = HeartPath().path(in: CGRect(x: 0, y: 0, width: 1, height: 1))
    .controlPoints(count: 500)
let heartBreakControlPoints: AnimatableVector = HeartBreakPath().path(in: CGRect(x: 0, y: 0, width: 1, height: 1))
    .controlPoints(count: 500)

struct HeartPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        // Start at the top-left corner
        path.move(to: CGPoint(x: 0.28061*width, y: 0.03662*height))
        
        // Construct the path in a clockwise direction
        path.addCurve(to: CGPoint(x: 0.49989*width, y: 0.17442*height), control1: CGPoint(x: 0.37868*width, y: 0.03662*height), control2: CGPoint(x: 0.45513*width, y: 0.09164*height))
        path.addCurve(to: CGPoint(x: 0.71917*width, y: 0.03662*height), control1: CGPoint(x: 0.54566*width, y: 0.09114*height), control2: CGPoint(x: 0.6211*width, y: 0.03662*height))
        path.addCurve(to: CGPoint(x: 0.99931*width, y: 0.3415*height), control1: CGPoint(x: 0.87709*width, y: 0.03662*height), control2: CGPoint(x: 0.99931*width, y: 0.16281*height))
        path.addCurve(to: CGPoint(x: 0.5366*width, y: 0.94975*height), control1: CGPoint(x: 0.99931*width, y: 0.55653*height), control2: CGPoint(x: 0.81976*width, y: 0.76803*height))
        path.addCurve(to: CGPoint(x: 0.49989*width, y: 0.96338*height), control1: CGPoint(x: 0.52554*width, y: 0.95631*height), control2: CGPoint(x: 0.51045*width, y: 0.96338*height))
        path.addCurve(to: CGPoint(x: 0.46368*width, y: 0.94975*height), control1: CGPoint(x: 0.48933*width, y: 0.96338*height), control2: CGPoint(x: 0.47424*width, y: 0.95631*height))
        path.addCurve(to: CGPoint(x: 0.00047*width, y: 0.3415*height), control1: CGPoint(x: 0.18002*width, y: 0.76803*height), control2: CGPoint(x: 0.00047*width, y: 0.55653*height))
        path.addCurve(to: CGPoint(x: 0.28061*width, y: 0.03662*height), control1: CGPoint(x: 0.00047*width, y: 0.16281*height), control2: CGPoint(x: 0.12268*width, y: 0.03662*height))
        
        path.closeSubpath()
        return path
    }
}

struct HeartBreakPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.40233*width, y: 0.85547*height))
        path.addCurve(to: CGPoint(x: 0.2617*width, y: 0.74219*height), control1: CGPoint(x: 0.37264*width, y: 0.825*height), control2: CGPoint(x: 0.30936*width, y: 0.77422*height))
        path.addCurve(to: CGPoint(x: 0.0367*width, y: 0.52266*height), control1: CGPoint(x: 0.15467*width, y: 0.67031*height), control2: CGPoint(x: 0.06483*width, y: 0.58203*height))
        path.addCurve(to: CGPoint(x: 0.09295*width, y: 0.13984*height), control1: CGPoint(x: -0.02267*width, y: 0.39609*height), control2: CGPoint(x: 0.00155*width, y: 0.23125*height))
        path.addCurve(to: CGPoint(x: 0.40233*width, y: 0.12891*height), control1: CGPoint(x: 0.18202*width, y: 0.05156*height), control2: CGPoint(x: 0.30233*width, y: 0.04688*height))
        path.addLine(to: CGPoint(x: 0.4367*width, y: 0.15703*height))
        path.addLine(to: CGPoint(x: 0.39061*width, y: 0.22031*height))
        path.addCurve(to: CGPoint(x: 0.34373*width, y: 0.28906*height), control1: CGPoint(x: 0.36483*width, y: 0.25547*height), control2: CGPoint(x: 0.34373*width, y: 0.28594*height))
        path.addCurve(to: CGPoint(x: 0.40545*width, y: 0.35469*height), control1: CGPoint(x: 0.34373*width, y: 0.29141*height), control2: CGPoint(x: 0.37186*width, y: 0.32109*height))
        path.addLine(to: CGPoint(x: 0.46717*width, y: 0.41641*height))
        path.addLine(to: CGPoint(x: 0.43592*width, y: 0.48047*height))
        path.addLine(to: CGPoint(x: 0.40389*width, y: 0.54453*height))
        path.addLine(to: CGPoint(x: 0.44842*width, y: 0.60391*height))
        path.addCurve(to: CGPoint(x: 0.49217*width, y: 0.66953*height), control1: CGPoint(x: 0.47264*width, y: 0.63672*height), control2: CGPoint(x: 0.49217*width, y: 0.66641*height))
        path.addCurve(to: CGPoint(x: 0.45623*width, y: 0.71094*height), control1: CGPoint(x: 0.49217*width, y: 0.67344*height), control2: CGPoint(x: 0.47577*width, y: 0.69219*height))
        path.addCurve(to: CGPoint(x: 0.43436*width, y: 0.83985*height), control1: CGPoint(x: 0.40311*width, y: 0.76328*height), control2: CGPoint(x: 0.40311*width, y: 0.7625*height))
        path.addCurve(to: CGPoint(x: 0.45936*width, y: 0.90938*height), control1: CGPoint(x: 0.4492*width, y: 0.87735*height), control2: CGPoint(x: 0.46092*width, y: 0.9086*height))
        path.addCurve(to: CGPoint(x: 0.40233*width, y: 0.85547*height), control1: CGPoint(x: 0.4578*width, y: 0.91016*height), control2: CGPoint(x: 0.4328*width, y: 0.88594*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.51719*width, y: 0.84219*height))
        path.addLine(to: CGPoint(x: 0.50078*width, y: 0.76953*height))
        path.addLine(to: CGPoint(x: 0.54844*width, y: 0.7211*height))
        path.addLine(to: CGPoint(x: 0.59609*width, y: 0.67344*height))
        path.addLine(to: CGPoint(x: 0.54844*width, y: 0.59219*height))
        path.addLine(to: CGPoint(x: 0.50078*width, y: 0.51172*height))
        path.addLine(to: CGPoint(x: 0.54844*width, y: 0.46406*height))
        path.addLine(to: CGPoint(x: 0.59531*width, y: 0.41563*height))
        path.addLine(to: CGPoint(x: 0.53594*width, y: 0.33985*height))
        path.addCurve(to: CGPoint(x: 0.47656*width, y: 0.2586*height), control1: CGPoint(x: 0.50313*width, y: 0.29844*height), control2: CGPoint(x: 0.47656*width, y: 0.26172*height))
        path.addCurve(to: CGPoint(x: 0.53906*width, y: 0.18516*height), control1: CGPoint(x: 0.47656*width, y: 0.25469*height), control2: CGPoint(x: 0.50469*width, y: 0.22188*height))
        path.addCurve(to: CGPoint(x: 0.81641*width, y: 0.08203*height), control1: CGPoint(x: 0.63594*width, y: 0.08203*height), control2: CGPoint(x: 0.71562*width, y: 0.05234*height))
        path.addCurve(to: CGPoint(x: 0.96797*width, y: 0.22891*height), control1: CGPoint(x: 0.87734*width, y: 0.09922*height), control2: CGPoint(x: 0.94297*width, y: 0.16328*height))
        path.addCurve(to: CGPoint(x: 0.89844*width, y: 0.60781*height), control1: CGPoint(x: 1.02188*width, y: 0.37344*height), control2: CGPoint(x: 0.99766*width, y: 0.50391*height))
        path.addCurve(to: CGPoint(x: 0.75625*width, y: 0.725*height), control1: CGPoint(x: 0.87734*width, y: 0.62969*height), control2: CGPoint(x: 0.81328*width, y: 0.68281*height))
        path.addCurve(to: CGPoint(x: 0.59766*width, y: 0.8586*height), control1: CGPoint(x: 0.69922*width, y: 0.76797*height), control2: CGPoint(x: 0.62813*width, y: 0.82735*height))
        path.addCurve(to: CGPoint(x: 0.53828*width, y: 0.91406*height), control1: CGPoint(x: 0.56797*width, y: 0.88906*height), control2: CGPoint(x: 0.54141*width, y: 0.91406*height))
        path.addCurve(to: CGPoint(x: 0.51719*width, y: 0.84219*height), control1: CGPoint(x: 0.53594*width, y: 0.91406*height), control2: CGPoint(x: 0.52656*width, y: 0.88125*height))
        path.closeSubpath()
        return path
    }
}

struct MorphView: View {
    @State var controlPoints: AnimatableVector = circleControlPoints
    @State var morphProgress: Double = 0.0
    @State var dragOffset: CGSize = .zero
    @State private var isAnimating = false

    let screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        MorphableShape(controlPoints: self.controlPoints)
            .frame(width: 64, height: 64)
            .keyframeAnimator(initialValue: AnimationValues(), trigger: isAnimating) { content, value in
                content
                    .foregroundStyle(Color(UIColor.systemPink))
                    // Apply rotation/tilt
                    .rotation3DEffect(value.horizontalSpin, axis: (x: 0, y: 1, z: 0))
                    // Apply scaling and vertical stretch
                    .scaleEffect(value.scale)
                    .scaleEffect(y: value.verticalStretch)
                    .scaleEffect(x: value.horizontalStretch)
                    // Apply vertical translation (bouncing effect)
                    .offset(y: value.verticalTranslation)
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
                    LinearKeyframe(1.0, duration: 0.5)  // Delay the heartbeat start
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
            .offset(x: self.dragOffset.width)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let dragDistance = gesture.translation.width
                        let maxDragDistance = self.screenWidth / 4
                        
                        // Determine progress based on drag direction
                        let progress = max(0, min(1, abs(dragDistance) / maxDragDistance)) // Clamp the progress between 0 and 1
                        
                        // Update the morph progress and control points based on drag direction
                        if dragDistance >= 0 {
                            self.morphProgress = progress
                            self.controlPoints = self.interpolatedControlPoints(from: circleControlPoints, to: heartControlPoints, progress: progress)
                        } else {
                            self.morphProgress = progress
                            self.controlPoints = self.interpolatedControlPoints(from: circleControlPoints, to: heartBreakControlPoints, progress: progress)
                        }
                        
                        // Update the offset directly
                        self.dragOffset = CGSize(width: dragDistance, height: 0)
                    }
                    .onEnded { _ in
                        if self.morphProgress == 1 {
                            isAnimating.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                    self.dragOffset = .zero
                                }
                                
                                withAnimation(.easeOut(duration: 0.3)) {
                                    self.morphProgress = 0.0
                                    self.controlPoints = circleControlPoints
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                self.dragOffset = .zero
                            }
                            withAnimation(.easeOut(duration: 0.3)) {
                                self.morphProgress = 0.0
                                self.controlPoints = circleControlPoints
                            }
                        }
                    }
            )
 
    }
    
    func interpolatedControlPoints(from: AnimatableVector, to: AnimatableVector, progress: Double) -> AnimatableVector {
        let interpolatedValues = zip(from.values, to.values).map { start, end in
            start + (end - start) * progress
        }
        return AnimatableVector(with: interpolatedValues)
    }
}

#Preview {
    MorphView()
}
