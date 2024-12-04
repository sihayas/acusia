//
//  AuxiliaryView.swift
//  acusia
//
//  Created by decoherence on 11/9/24.
//

import SwiftUI

struct AuxiliaryView: View {
    @State private var isCollapsed: Bool = false
    @State private var hasAppeared: Bool = false
    @State private var pathProgress: CGFloat = 0
    let size: CGSize

    @Binding var gestureTranslation: CGPoint
    @Binding var gestureVelocity: CGPoint

    var body: some View {
        GeometryReader { geometry in
            let icons = Array(repeating: "circle.fill", count: 5)
            let pathShape = CurvedPathShape(trigger: isCollapsed ? 1 : 0, pathProgress: pathProgress)
            let path = pathShape.path(in: CGRect(origin: .zero, size: geometry.size))

            let adjustedTranslation = CGPoint(
                x: geometry.size.width + gestureTranslation.x * 2.5,
                y: geometry.size.height + gestureTranslation.y * 2.5
            )

            pathShape
                .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 55, lineCap: .round))

            let iconPositions = icons.indices.map { index -> CGPoint in
                let fraction = CGFloat(index) / CGFloat(icons.count - 1) * pathProgress
                return path.point(atFractionOfLength: fraction)
            }
            
            let closestIndex = iconPositions
                .enumerated()
                .min(by: { adjustedTranslation.distance(to: $0.element) < adjustedTranslation.distance(to: $1.element) })?
                .offset

            ForEach(icons.indices, id: \.self) { index in
                let position = iconPositions[index]
                let isClosest = (index == closestIndex)

                Image(systemName: icons[index])
                    .font(.system(size: 22))
                    .scaleEffect(isClosest ? 2.0 : 1.0)
                    .position(x: position.x, y: position.y)
                    .animation(.snappy(), value: isClosest)
                    .sensoryFeedback(trigger: isClosest) { _, _ in
                        .impact(flexibility: .soft, intensity: 0.25)
                    }
            }
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .onTapGesture {
            withAnimation(.smooth()) { isCollapsed.toggle() }
        }
        .onAppear {
            withAnimation(.smooth()) {
                hasAppeared = true
                pathProgress = 1.0
            }
        }
    }
}

struct CurvedPathShape: Shape, Animatable {
    var trigger: CGFloat
    var pathProgress: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(trigger, pathProgress) }
        set {
            trigger = newValue.first
            pathProgress = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.height * 0.25, y: rect.maxY - rect.height * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + rect.height * 0.75, y: rect.minY + rect.height * 0.25),
            control: CGPoint(x: rect.minX + rect.height * 0.25, y: rect.minY + rect.height * 0.25)
        )

        let startX = rect.maxX - rect.height * 0.25
        let endX = rect.minX + rect.height * 0.75
        let x = startX * (1 - trigger) + endX * trigger
        path.addLine(to: CGPoint(x: x, y: rect.minY + rect.height * 0.25))

        return path.trimmedPath(from: 0, to: pathProgress)
    }
}
