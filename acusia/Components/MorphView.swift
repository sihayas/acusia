//
//  MorphView.swift
//  acusia
//
//  Created by decoherence on 9/2/24.
//

import SwiftUI
import Wave

#Preview {
    MorphView()
}


struct MorphView: View {
    @State var controlPoints: AnimatableVector = circleControlPoints
    @State var morphProgress: Double = 0.0
    @State var dragOffset: CGSize = .zero

    let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    let offsetAnimator = SpringAnimator<CGPoint>(spring: Spring(dampingRatio: 0.72, response: 0.7))

    @State var boxOffset: CGPoint = .zero

    var body: some View {
        MorphableShape(controlPoints: self.controlPoints)
            .frame(width: 64, height: 64)
            .onAppear {
                offsetAnimator.value = .zero

                // The offset animator's callback will update the `offset` state variable.
                offsetAnimator.valueChanged = { newValue in
                    boxOffset = newValue
                }
            }
            .offset(x: boxOffset.x, y: boxOffset.y)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Update the animator's target to the new drag translation.
                        offsetAnimator.target = CGPoint(x: value.translation.width, y: value.translation.height)

                        // Don't animate the box's position when we're dragging it.
                        offsetAnimator.mode = .nonAnimated
                        offsetAnimator.start()
                    }
                    .onEnded { value in
                        // Animate the box to its original location (i.e. with zero translation).
                        offsetAnimator.target = .zero

                        // We want the box to animate to its original location, so use an `animated` mode.
                        // This is different than the
                        offsetAnimator.mode = .animated

                        // Take the velocity of the gesture, and give it to the animator.
                        // This makes the throw animation feel natural and continuous.
                        offsetAnimator.velocity = CGPoint(x: value.velocity.width, y: value.velocity.height)
                        offsetAnimator.start()
                    }
            )
    }
    
    func interpolatedControlPoints(from: AnimatableVector, to: AnimatableVector, progress: Double) -> AnimatableVector {
        let interpolatedValues = zip(from.values, to.values).map { start, end in
            start + (end - start)*progress
        }
        return AnimatableVector(with: interpolatedValues)
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
