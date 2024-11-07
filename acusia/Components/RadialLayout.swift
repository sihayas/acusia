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

struct TriangularLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // Accept the full proposed space, replacing any nil values with defaults
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        
        // Calculate the number of rows needed for a triangle
        let totalRows = calculateRows(for: subviews.count)
        
        // Calculate spacing between elements
        let maxItemsInRow = totalRows // Bottom row will have this many items
        let horizontalSpacing = bounds.width / CGFloat(maxItemsInRow + 1)
        let verticalSpacing = bounds.height / CGFloat(totalRows + 1)
        
        var currentIndex = 0
        
        // Place views row by row
        for row in 0..<totalRows {
            let itemsInCurrentRow = row + 1
            let rowY = bounds.minY + verticalSpacing * CGFloat(row + 1)
            
            // Calculate starting X position for this row to center it
            let totalRowWidth = horizontalSpacing * CGFloat(itemsInCurrentRow - 1)
            let startX = bounds.midX - totalRowWidth / 2
            
            // Place items in the current row
            for item in 0..<itemsInCurrentRow {
                guard currentIndex < subviews.count else { return }
                
                let subview = subviews[currentIndex]
                let viewSize = subview.sizeThatFits(.unspecified)
                
                let xPos = startX + horizontalSpacing * CGFloat(item)
                let point = CGPoint(x: xPos, y: rowY)
                
                subview.place(at: point, anchor: .center, proposal: .unspecified)
                currentIndex += 1
            }
        }
    }
    
    // Helper function to calculate the number of rows needed
    private func calculateRows(for count: Int) -> Int {
        var items = 0
        var rows = 0
        
        while items < count {
            rows += 1
            items += rows
        }
        
        return rows
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
