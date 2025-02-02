//
//  TailPath.swift
//  acusia
//
//  Created by decoherence on 8/29/24.
//

import SwiftUI

// MARK: - Entity Paths
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}


// MARK: - Message Paths
struct MessageTailPath {
    func path(in rect: CGRect) -> UIBezierPath {
        let cornerRadius: CGFloat = 20
        let firstCircleSize: CGFloat = 12
        let secondCircleSize: CGFloat = 8

        let bubblePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

        // First circle (tail)
        let firstCircleRect = CGRect(
            x: rect.minX,
            y: rect.maxY - firstCircleSize,
            width: firstCircleSize,
            height: firstCircleSize
        )
        bubblePath.append(UIBezierPath(ovalIn: firstCircleRect))

        // Second smaller circle
        let secondCircleRect = CGRect(
            x: firstCircleRect.minX - secondCircleSize,
            y: firstCircleRect.maxY - secondCircleSize / 2,
            width: secondCircleSize,
            height: secondCircleSize
        )
        bubblePath.append(UIBezierPath(ovalIn: secondCircleRect))

        return bubblePath
    }
}

struct MessageTail: Shape {
    let isOwn = false

    func path(in rect: CGRect) -> Path {
        let bubbleRect = rect
        let bubble = RoundedRectangle(cornerRadius: 18, style: .continuous)
            .path(in: bubbleRect)

        let firstCircleSize: CGFloat = 12

        let tailRect = CGRect(
            x: isOwn
                ? bubbleRect.maxX - firstCircleSize
                : bubbleRect.minX,
            y: bubbleRect.minY + bubbleRect.height - firstCircleSize,

            width: firstCircleSize,
            height: firstCircleSize
        )
        let tail = Circle().path(in: tailRect)

        let secondCircleSize: CGFloat = 6
        let secondCircleRect = CGRect(
            x: isOwn
                ? tailRect.maxX + secondCircleSize * 0.25
                : tailRect.minX - secondCircleSize * 1.5,
            y: tailRect.maxY - secondCircleSize,
            width: secondCircleSize,
            height: secondCircleSize
        )
        let secondCircle = Circle().path(in: secondCircleRect)

        let combined = bubble.union(tail).union(secondCircle)

        return combined
    }
}

struct ContextMessageTail: Shape, InsettableShape {
    let isOwn = false
    var insetAmount: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let bubbleRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let bubble = RoundedRectangle(cornerRadius: 14, style: .continuous)
            .path(in: bubbleRect)

        let firstCircleSize: CGFloat = 8
        let tailRect = CGRect(
            x: isOwn
                ? bubbleRect.maxX - firstCircleSize
                : bubbleRect.minX,
            y: bubbleRect.maxY - firstCircleSize,
            width: firstCircleSize,
            height: firstCircleSize
        ).insetBy(dx: insetAmount, dy: insetAmount)
        
        let tail = Circle().path(in: tailRect)

        let secondCircleSize: CGFloat = 4
        let baseSecondCircleRect = CGRect(
            x: isOwn
                ? bubbleRect.maxX - firstCircleSize + firstCircleSize + secondCircleSize * 0.25
                : bubbleRect.minX - secondCircleSize * 1.75,
            y: bubbleRect.maxY - secondCircleSize,
            width: secondCircleSize,
            height: secondCircleSize
        )
        let secondCircleRect = baseSecondCircleRect.insetBy(dx: insetAmount, dy: insetAmount)
        let secondCircle = Circle().path(in: secondCircleRect)

        return bubble.union(tail).union(secondCircle)
    }
    
    func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}


struct BlipTail: InsettableShape {
    var insetAmount: CGFloat = 0
    var isFlipped: Bool = false
    
    func path(in rect: CGRect) -> Path {
        // Calculate the base sizes
        let tailSize: CGFloat = rect.height * 0.3
        let secondCircleSize: CGFloat = tailSize * 0.5
        
        // Inset the main bubble
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let bubble = Circle().path(in: insetRect)
        
        // Calculate and inset the tail circle
        let tailRect = CGRect(
            x: insetRect.maxX - tailSize,
            y: insetRect.maxY - tailSize,
            width: tailSize,
            height: tailSize
        ).insetBy(dx: insetAmount, dy: insetAmount)
        let tail = Circle().path(in: tailRect)
        
        // Calculate and inset the second circle
        // First calculate the base position without inset
        let baseSecondCircleRect = CGRect(
            x: rect.maxX - tailSize + tailSize + secondCircleSize,
            y: rect.maxY - secondCircleSize,
            width: secondCircleSize,
            height: secondCircleSize
        )
        // Then apply the inset to both position and size
        let secondCircleRect = CGRect(
            x: baseSecondCircleRect.origin.x + insetAmount,
            y: baseSecondCircleRect.origin.y + insetAmount,
            width: baseSecondCircleRect.width - (insetAmount * 2),
            height: baseSecondCircleRect.height - (insetAmount * 2)
        )
        let secondCircle = Circle().path(in: secondCircleRect)
        
        // Combine all inset shapes
        let combined = bubble.union(tail).union(secondCircle)
        
        if isFlipped {
            let transform = CGAffineTransform(scaleX: -1, y: 1)
                .translatedBy(x: -rect.width, y: 0)
            return combined.applying(transform)
        }
        return combined
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

// MARK: Thread Paths


struct TopLeadingToBottomCenterPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + rect.width / 2))

        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )

        return path
    }
}

struct TopCenterToBottomTrailingPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the curve
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width / 2))

        // Draw the rounded corner curve to the right center
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct ConnectedRepliesPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Draw the top curve to the center
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY + rect.width / 2),
                          control: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the bottom curve
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width / 2))

        // Draw the bottom curve back to the left
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct LoopPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0.95*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.75*height))
        path.addCurve(to: CGPoint(x: 0.20953*width, y: 0.26027*height), control1: CGPoint(x: 0.5*width, y: 0.51429*height), control2: CGPoint(x: 0.36032*width, y: 0.26027*height))
        path.addCurve(to: CGPoint(x: 0.03333*width, y: 0.50961*height), control1: CGPoint(x: 0.05874*width, y: 0.26027*height), control2: CGPoint(x: 0.03333*width, y: 0.41697*height))
        path.addCurve(to: CGPoint(x: 0.20956*width, y: 0.74652*height), control1: CGPoint(x: 0.03333*width, y: 0.60226*height), control2: CGPoint(x: 0.06435*width, y: 0.74652*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.25*height), control1: CGPoint(x: 0.3771*width, y: 0.74652*height), control2: CGPoint(x: 0.5*width, y: 0.50267*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.05*height))
        return path
    }
}
