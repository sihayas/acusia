//
//  RadialLayout.swift
//  acusia
//
//  Created by decoherence on 10/12/24.
//

import SwiftUI

struct RadialLayout: Layout {
    var radius: CGFloat
    var offset: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Use the container’s proposal to find a concrete size
        let size = proposal.replacingUnspecifiedDimensions()
        return size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let angle = 2 * .pi / CGFloat(subviews.count)

        for (index, subview) in subviews.enumerated() {
            // Find a point using the angle and offset
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(rotationAngle: angle * CGFloat(index) + offset))

            // Shift to the middle of the bounds
            point.x += bounds.midX
            point.y += bounds.midY

            // Place the subview
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}
