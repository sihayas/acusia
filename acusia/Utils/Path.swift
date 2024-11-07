//
//  Path.swift
//  acusia
//
//  Created by decoherence on 11/6/24.
//
import SwiftUI

extension CGPoint {
    // Helper function to calculate distance between two points
    func distance(to other: CGPoint) -> CGFloat {
        return hypot(x - other.x, y - other.y)
    }
}

extension Path {
    func point(atFractionOfLength fraction: CGFloat) -> CGPoint {
        if fraction <= 0 {
            // Get the starting point of the path
            var startPoint: CGPoint = .zero
            self.forEach { element in
                if case let .move(to: point) = element {
                    startPoint = point
                    return
                }
            }
            return startPoint
        } else if fraction >= 1 {
            // Get the end point of the path
            var endPoint: CGPoint = .zero
            self.forEach { element in
                if case let .move(to: point) = element {
                    endPoint = point
                } else if case let .line(to: point) = element {
                    endPoint = point
                } else if case let .quadCurve(to: point, control: _) = element {
                    endPoint = point
                } else if case let .curve(to: point, control1: _, control2: _) = element {
                    endPoint = point
                } else if case .closeSubpath = element {
                    // Do nothing for close subpath
                }
            }
            return endPoint
        } else {
            let trimmedPath = self.trimmedPath(from: 0, to: fraction)
            return trimmedPath.currentPoint ?? .zero
        }
    }
}
