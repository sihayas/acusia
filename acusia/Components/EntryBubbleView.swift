//
//  EntryBubbleView.swift
//  acusia
//
//  Created by decoherence on 10/29/24.
//
import SwiftUI
import ContextMenuAuxiliaryPreview


#Preview {
    AuxiliaryPreview()
        .background(DarkModeWindowModifier())
}


struct CurvedPathShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.22, y: rect.height * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.78),
            control: CGPoint(x: rect.width * 0.8, y: rect.height * 0.2)
        )
        return path
    }
}

struct AuxiliaryView: View {
    @State private var width: CGFloat = 124
    @GestureState private var isDragging: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let pathShape = CurvedPathShape()

            pathShape
                .stroke(Color(.systemGray5), style: StrokeStyle(
                    lineWidth: geometry.size.height * 0.45,
                    lineCap: .round
                ))

            let icons = ["circle.fill", "suit.heart.fill", "circle.fill"]
            let path = pathShape.path(in: geometry.frame(in: .local))

            ForEach(0..<icons.count, id: \.self) { index in
                let fraction = CGFloat(index) / CGFloat(icons.count - 1)
                let position = path.point(atFractionOfLength: fraction)

                Image(systemName: icons[index])
                    .font(.system(size: 22))
                    .position(x: position.x, y: position.y)
            }
        }
        .frame(width: width, height: 124)
        .border(.red)
        .offset(x: 64)
        .gesture(
            DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                    // Change width as soon as drag starts
                    withAnimation(.spring()) {
                        width = 180
                    }
                }
                .onEnded { _ in
                    // Reset width when drag ends
                    withAnimation(.spring()) {
                        width = 124
                    }
                }
        )
    }
}


struct EntryBubble: View {
    let entry: EntryModel
    let color: Color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(entry.text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color, in: BubbleWithTailShape(scale: 1))
            .foregroundStyle(.secondary)
            .contentShape(BubbleWithTailShape(scale: 1))
            .auxiliaryContextMenu(
                 auxiliaryContent: AuxiliaryView(),
                 config: AuxiliaryPreviewConfig(
                    verticalAnchorPosition: .top,
                    horizontalAlignment: .stretch,
                    preferredWidth: .constant(124),
                    preferredHeight: .constant(124),
                    marginInner: -64, // Distance between the auxiliary view and the target view
                    marginOuter: 0, // Distance between the auxiliary view and the screen edge
                    transitionConfigEntrance: .syncedToMenuEntranceTransition(),
                    transitionExitPreset: .zoom(zoomOffset: 0.5)
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
