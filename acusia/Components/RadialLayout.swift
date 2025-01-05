import SwiftUI

struct GreedyPackingLayout: Layout {
    /// Radii of circles to place, largest first
    let circleRadii: [CGFloat]
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard subviews.count == circleRadii.count else { return }
        
        let layoutCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let boundingRadius = min(bounds.width, bounds.height) / 2
        
        // Positions of placed circles
        var placedCenters: [CGPoint] = []
        
        for (index, subview) in subviews.enumerated() {
            let r = circleRadii[index]
            
            // Find a spot
            if let foundCenter = placeCircle(
                radius: r,
                boundingRadius: boundingRadius,
                layoutCenter: layoutCenter,
                placedCenters: placedCenters,
                placedRadii: Array(circleRadii.prefix(index))
            ) {
                // Place it
                let size = CGSize(width: 2*r, height: 2*r)
                subview.place(
                    at: foundCenter,
                    anchor: .center,
                    proposal: ProposedViewSize(size)
                )
                placedCenters.append(foundCenter)
            } else {
                // Couldn’t find a valid spot, skip or fail
                // For simplicity, just place offscreen
                subview.place(at: CGPoint(x: -9999, y: -9999),
                              anchor: .center,
                              proposal: .unspecified)
            }
        }
    }
    
    /// Attempts to place a circle of radius `r` inside the bounding circle,
    /// avoiding overlap with already placed circles.
    private func placeCircle(
        radius r: CGFloat,
        boundingRadius: CGFloat,
        layoutCenter: CGPoint,
        placedCenters: [CGPoint],
        placedRadii: [CGFloat]
    ) -> CGPoint? {
        
        // Quick brute-force spiral search from center
        let maxAttempts = 20000
        let step: CGFloat = 2.0
        
        for attempt in 0..<maxAttempts {
            // Spiral outward
            let angle = CGFloat(attempt) * 0.5  // (roughly) radians
            let dist = step * CGFloat(attempt).squareRoot()
            
            let candidate = CGPoint(
                x: layoutCenter.x + dist * cos(angle),
                y: layoutCenter.y + dist * sin(angle)
            )
            
            // Check bounding circle
            if distance(candidate, layoutCenter) + r > boundingRadius {
                continue
            }
            
            // Check overlap with previously placed circles
            var hasOverlap = false
            for (i, c) in placedCenters.enumerated() {
                if distance(candidate, c) < (r + placedRadii[i]) {
                    hasOverlap = true
                    break
                }
            }
            if !hasOverlap { return candidate }
        }
        
        // Didn’t find a valid spot
        return nil
    }
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx*dx + dy*dy)
    }
}

struct GreedyPackingDemo: View {
    let circles: [CGFloat] = [80, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40]

    var body: some View {
        GreedyPackingLayout(circleRadii: circles) {
            ForEach(circles.indices, id: \.self) { i in
                Circle().fill(color(for: i))
            }
        }
        .frame(width: 400, height: 400)
        .overlay(Circle().stroke(Color.red, lineWidth: 2))
        .background(Color.gray.opacity(0.2))
    }
    
    func color(for index: Int) -> Color {
        // Just a quick color variation
        Color(hue: Double(index) / Double(circles.count),
              saturation: 0.7,
              brightness: 0.9)
    }
}

#Preview {
    GreedyPackingDemo()
}
