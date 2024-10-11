import SwiftUI

struct AnimatedEdgeCurve: View {
    @State private var bulgeProgress: CGFloat = 0
    @State private var liftProgress: CGFloat = 0

    var body: some View {
        GeometryReader { _ in
            ZStack {
                WispView(entry: entries[0])
                    .background(.black)

                CurveShape(bulgeProgress: bulgeProgress, liftProgress: liftProgress)
                    .fill(Color(UIColor.systemGray3))
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6),
                        value: bulgeProgress
                    )
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6),
                        value: liftProgress
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
        }
        .onTapGesture {
            if bulgeProgress == 0 {
                // First tap: Animate the bulge
                bulgeProgress = 1
            } else if liftProgress == 0 {
                // Second tap: Animate the lifting effect
                liftProgress = 1
            } else {
                // Third tap: Reset both animations
                bulgeProgress = 0
                liftProgress = 0
            }
        }
    }
}

struct CurveShape: Shape {
    var bulgeProgress: CGFloat
    var liftProgress: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(bulgeProgress, liftProgress) }
        set {
            bulgeProgress = newValue.first
            liftProgress = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Bulge width based on bulgeProgress
        let maxBulgeWidth = width * 0.10
        let bulgeWidth = maxBulgeWidth * bulgeProgress

        // Side straightness adjustment based on liftProgress
        let sideStraightness = liftProgress

        // Adjust the side x-coordinate to straighten sides during lift
        let sideX = width - bulgeWidth + (bulgeWidth * 0.3 * sideStraightness)

        // Adjust the control points vertically to flatten the curves near the top and bottom edges
        let topControlY = height * (0.3 - 0.2 * sideStraightness)
        let bottomControlY = height * (0.7 + 0.2 * sideStraightness)

        // Start from the top-right corner
        path.move(to: CGPoint(x: width, y: 0))

        // First Bezier curve (top to middle)
        path.addCurve(
            to: CGPoint(x: sideX, y: height / 2),
            control1: CGPoint(x: width, y: topControlY),
            control2: CGPoint(x: sideX, y: height * 0.3 - (height * 0.1 * sideStraightness))
        )

        // Second Bezier curve (middle to bottom)
        path.addCurve(
            to: CGPoint(x: width, y: height),
            control1: CGPoint(x: sideX, y: height * 0.7 + (height * 0.1 * sideStraightness)),
            control2: CGPoint(x: width, y: bottomControlY)
        )

        // Close the path
        path.closeSubpath()

        return path
    }
}

struct AnimatedEdgeCurve_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedEdgeCurve()
            .background(.black)
    }
}
 
