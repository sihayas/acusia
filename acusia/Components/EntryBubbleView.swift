//
//  EntryBubbleView.swift
//  acusia
//
//  Created by decoherence on 10/29/24.
//
import SwiftUI
import ContextMenuAuxiliaryPreview

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
                .stroke(Color(UIColor.systemGray5), style: StrokeStyle(lineWidth: 55, lineCap: .round))

            // Compute closest icon
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
                    .sensoryFeedback(trigger: isClosest) { oldValue, newValue in
                        return .impact(flexibility: .soft, intensity: 0.25)
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

extension CGPoint {
    // Helper function to calculate distance between two points
    func distance(to other: CGPoint) -> CGFloat {
        return hypot(x - other.x, y - other.y)
    }
}



struct EntryBubble: View {
    let entry: EntryModel
    let color: Color
    
    let auxiliarySize: CGSize = CGSize(width: 216, height: 120)
    
    @State private var gestureTranslation = CGPoint.zero
    @State private var gestureVelocity = CGPoint.zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(entry.text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(6)
                    .onChange(of: gestureTranslation) {_, newValue in
                        print("Gesture translation: \(newValue)")
                    }
                    .onChange(of: gestureVelocity) {_, newValue in
                        // print("Gesture velocity: \(newValue)")
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color, in: BubbleWithTailShape(scale: 1))
            .foregroundStyle(.secondary)
            .auxiliaryContextMenu(
                auxiliaryContent: AuxiliaryView(size: auxiliarySize, gestureTranslation: $gestureTranslation, gestureVelocity: $gestureVelocity),
                 gestureTranslation: $gestureTranslation,
                 gestureVelocity: $gestureVelocity,
                 config: AuxiliaryPreviewConfig(
                    verticalAnchorPosition: .top,
                    horizontalAlignment: .targetLeading,
                    preferredWidth:  .constant(auxiliarySize.width),
                    preferredHeight: .constant(auxiliarySize.height),
                    marginInner: -56,
                    marginOuter: 0,
                    marginLeading: -56,
                    marginTrailing: 0,
                    transitionConfigEntrance: .syncedToMenuEntranceTransition(),
                    transitionExitPreset: .zoom(zoomOffset: 0)
                  )
             ) {
                 UIAction(
                     title: "Share",
                     image: UIImage(systemName: "square.and.arrow.up")
                 ) { _ in
                     // Action handler
                 }
             }
            .overlay(alignment: .topLeading) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(entry.username)
                        .foregroundColor(.secondary)
                        .font(.system(size: 11, weight: .regular))

                    if let artist = entry.artistName, let album = entry.name {
                        Text("·")
                            .foregroundColor(.secondary)
                            .font(.system(size: 11, weight: .bold))

                        VStack(alignment: .leading) {
                            Text("\(artist), \(album)")
                                .foregroundColor(.secondary)
                                .font(.system(size: 11, weight: .semibold))
                                .lineLimit(1)
                        }
                    }
                }
                .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }


            BlipView(size: CGSize(width: 60, height: 60), fill: color)
                .alignmentGuide(VerticalAlignment.top) { d in d.height / 1.5 }
                .alignmentGuide(HorizontalAlignment.trailing) { d in d.width * 1.0 }
                .offset(x: 20, y: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EntryBubbleOutlined: View {
    let entry: EntryModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(entry.text)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay(
                BubbleWithTailShape(scale: 0.7)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                Text(entry.username)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                    .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
