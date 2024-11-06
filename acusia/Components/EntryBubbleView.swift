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
        path.move(to: CGPoint(x: rect.maxX - rect.height * 0.25, y: rect.maxY - rect.height * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - rect.height * 0.75, y: rect.minY + rect.height * 0.25),
            control: CGPoint(x: rect.maxX - rect.height * 0.25, y: rect.minY + rect.height * 0.25)
        )

        let x = rect.minX + rect.height * 0.25 + (trigger * ((rect.maxX - rect.height * 0.75) - (rect.minX + rect.height * 0.25)))
        path.addLine(to: CGPoint(x: x, y: rect.minY + rect.height * 0.25))

        return path.trimmedPath(from: 0, to: pathProgress)
    }
}

struct AuxiliaryView: View {
    @State private var isCollapsed: Bool = false
    @State private var hasAppeared: Bool = false
    @State private var pathProgress: CGFloat = 0

    let size: CGSize

    var body: some View {
        GeometryReader { geometry in
            let pathShape = CurvedPathShape(trigger: isCollapsed ? 1 : 0, pathProgress: pathProgress)

            pathShape
                .stroke(Color(.systemGray5), style: StrokeStyle(
                    lineWidth: 55,
                    lineCap: .round
                ))

            let icons = ["circle.fill", "suit.heart.fill", "circle.fill", "suit.club.fill", "circle.fill"]
            let path = pathShape.path(in: geometry.frame(in: .local))

            // ForEach(0..<icons.count, id: \.self) { index in
            //     let fraction = CGFloat(index) / CGFloat(icons.count - 1)
            //     let adjustedFraction = fraction * pathProgress
            //     let position = path.point(atFractionOfLength: adjustedFraction)
            //
            //     Image(systemName: icons[index])
            //         .font(.system(size: 22))
            //         .position(x: position.x, y: position.y)
            // }
        }
        .frame(width: size.width, height: size.height, alignment: .trailing)
        .onTapGesture {
            withAnimation(.smooth(duration: 0.4)) {
                isCollapsed.toggle()
            }
        }
        .onAppear {
            withAnimation(.smooth()) {
                hasAppeared = true
                pathProgress = 1.0
            }
        }
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
                        print("Gesture velocity: \(newValue)")
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color, in: BubbleWithTailShape(scale: 1))
            .foregroundStyle(.secondary)
            .auxiliaryContextMenu(
                 auxiliaryContent: AuxiliaryView(size: auxiliarySize),
                 gestureTranslation: $gestureTranslation,
                 gestureVelocity: $gestureVelocity,
                 config: AuxiliaryPreviewConfig(
                    verticalAnchorPosition: .top,
                    horizontalAlignment: .targetTrailing,
                    preferredWidth:  .constant(auxiliarySize.width),
                    preferredHeight: .constant(auxiliarySize.height),
                    marginInner: -56,
                    marginOuter: 0,
                    marginLeading: 0,
                    marginTrailing: 64,
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
        .padding(.trailing, 40)
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
        // .frame(maxWidth: .infinity, alignment: .leading)
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
