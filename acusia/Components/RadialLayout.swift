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

struct ZigZagLayout: Layout {
    var spacing: CGFloat = 20  // Horizontal spacing between items
    var rowSpacing: CGFloat = 20  // Vertical spacing between rows
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxItemSize = sizes.reduce(.zero) { CGSize(
            width: max($0.width, $1.width),
            height: max($0.height, $1.height)
        )}
        
        // Calculate number of items per row (first row)
        let firstRowCount = (subviews.count + 1) / 2
        let secondRowCount = subviews.count / 2
        
        // Calculate total width needed
        let firstRowWidth = maxItemSize.width * CGFloat(firstRowCount) + spacing * CGFloat(firstRowCount - 1)
        let secondRowWidth = maxItemSize.width * CGFloat(secondRowCount) + spacing * CGFloat(secondRowCount - 1)
        
        return CGSize(
            width: max(firstRowWidth, secondRowWidth),
            height: maxItemSize.height * 2 + rowSpacing
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxItemSize = sizes.reduce(.zero) { CGSize(
            width: max($0.width, $1.width),
            height: max($0.height, $1.height)
        )}
        
        // Calculate number of items for each row
        let firstRowCount = (subviews.count + 1) / 2
        
        // Calculate starting positions
        let firstRowY = bounds.minY
        let secondRowY = firstRowY + maxItemSize.height + rowSpacing
        
        // Place first row items
        var currentX = bounds.minX
        for index in 0..<firstRowCount {
            let subview = subviews[index]
            subview.place(
                at: CGPoint(x: currentX + maxItemSize.width / 2, y: firstRowY + maxItemSize.height / 2),
                anchor: .center,
                proposal: ProposedViewSize(width: maxItemSize.width, height: maxItemSize.height)
            )
            currentX += maxItemSize.width + spacing
        }
        
        // Place second row items (offset to center between top items)
        currentX = bounds.minX + (maxItemSize.width + spacing) / 2
        for index in firstRowCount..<subviews.count {
            let subview = subviews[index]
            subview.place(
                at: CGPoint(x: currentX + maxItemSize.width / 2, y: secondRowY + maxItemSize.height / 2),
                anchor: .center,
                proposal: ProposedViewSize(width: maxItemSize.width, height: maxItemSize.height)
            )
            currentX += maxItemSize.width + spacing
        }
    }
}

import SwiftUI

struct ConcentricRadialLayout: Layout {
    var innerRadius: CGFloat  // Size of the first circle
    var ringSpacing: CGFloat = 20  // Space between rings
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // Accept the full proposed space
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        
        // Place first item in center
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        if let firstView = subviews.first {
            firstView.place(at: centerPoint, anchor: .center, proposal: .unspecified)
        }
        
        // Skip the first view as it's in the center
        let remainingViews = subviews.dropFirst()
        guard !remainingViews.isEmpty else { return }
        
        // Calculate rings needed (roughly square root of remaining items)
        let ringCount = Int(ceil(sqrt(Double(remainingViews.count))))
        var currentIndex = 0
        
        // Place items in concentric rings
        for ring in 1...ringCount {
            // Calculate number of items that can fit in this ring
            let itemsInRing = min(ring * 6, remainingViews.count - currentIndex)
            guard itemsInRing > 0 else { break }
            
            // Calculate radius for this ring
            let ringRadius = innerRadius + (ringSpacing * CGFloat(ring))
            
            // Calculate angle between items in this ring
            let angle = Angle.degrees(360.0 / Double(itemsInRing)).radians
            
            // Place items in this ring
            for item in 0..<itemsInRing {
                let index = currentIndex + item
                guard index < remainingViews.count else { break }
                
                let view = remainingViews.dropFirst(currentIndex)[item]
                let viewSize = view.sizeThatFits(.unspecified)
                
                // Calculate position on the circle
                let itemAngle = angle * Double(item) - .pi / 2
                let xPos = cos(itemAngle) * (ringRadius - viewSize.width / 2)
                let yPos = sin(itemAngle) * (ringRadius - viewSize.height / 2)
                
                // Position the view
                let point = CGPoint(x: bounds.midX + xPos, y: bounds.midY + yPos)
                view.place(at: point, anchor: .center, proposal: .unspecified)
            }
            
            currentIndex += itemsInRing
        }
    }
}

// Example usage:
struct ContentView: View {
    var body: some View {
        ConcentricRadialLayout(innerRadius: 50, ringSpacing: 60) {
            ForEach(0..<20) { index in
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 40, height: 40)
                    .overlay(Text("\(index)"))
            }
        }
        .frame(width: 500, height: 500)
    }
}

#Preview {
    ContentView()
}
