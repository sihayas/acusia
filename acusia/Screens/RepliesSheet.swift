//
//  ReplySheet.swift
//  acusia
//
//  Created by decoherence on 9/8/24.
//
import SwiftUI
import Transmission

class LayerManager: ObservableObject {
    @Published var layers: [Layer] = [Layer()]

    func pushLayer() {
        layers.append(Layer())
    }

    func popLayer(at index: Int) {
        if layers.indices.contains(index) {
            layers.remove(at: index)
        }
    }

    func updateOffsets(collapsedOffset: CGFloat) {
        var totalOffset: CGFloat = 0

        for index in 0 ..< layers.count {
            if layers[index].isCollapsed {
                totalOffset -= collapsedOffset
                layers[index].offsetY = totalOffset
            }
        }
    }

    struct Layer: Identifiable {
        let id = UUID()
        var state: LayerState = .expanded
        var offsetY: CGFloat = 0 // For animating off-screen

        var isCollapsed: Bool {
            state.isCollapsed
        }

        var dynamicHeight: CGFloat? {
            state.dynamicHeight
        }
    }

    enum LayerState {
        case expanded
        case collapsed(height: CGFloat)

        var isCollapsed: Bool {
            if case .collapsed = self {
                return true
            }
            return false
        }

        var dynamicHeight: CGFloat? {
            switch self {
            case .expanded:
                return nil
            case .collapsed(let height):
                return height
            }
        }
    }
}

struct RepliesSheet: View {
    @EnvironmentObject private var windowState: WindowState
    @StateObject private var layerManager = LayerManager()

    var size: CGSize

    var body: some View {
        let heightCenter = size.height / 2
        let collapsedHeight = size.height * 0.21
        let collapsedOffset = size.height * 0.07

        ZStack(alignment: .bottom) {
            ForEach(Array(layerManager.layers.enumerated()), id: \.element.id) { index, layer in
                LayerView(
                    layerManager: layerManager,
                    sampleComments: sampleComments,
                    width: size.width,
                    height: size.height,
                    heightCenter: heightCenter,
                    collapsedHeight: collapsedHeight,
                    collapsedOffset: collapsedOffset,
                    layer: layer,
                    index: index
                )
                .zIndex(Double(layerManager.layers.count - index))
            }
        }
        .onReceive(layerManager.$layers) { layers in
            windowState.isLayered = layers.count > 1
        }
    }
}

struct LayerView: View {
    @EnvironmentObject private var windowState: WindowState
    @ObservedObject var layerManager: LayerManager

    @State private var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @State private var scrollDisabled = false
    @State private var isOffsetAtTop = true
    @State private var blurRadius: CGFloat = 0
    @State private var scale: CGFloat = 1

    let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow]
    let sampleComments: [Reply]
    let width: CGFloat
    let height: CGFloat
    let heightCenter: CGFloat
    let collapsedHeight: CGFloat
    let collapsedOffset: CGFloat
    let layer: LayerManager.Layer
    let index: Int
    let cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sampleComments) { reply in
                        ReplyView(reply: reply)
                    }
                }
                .padding(.horizontal, 24)
                .scaleEffect(scale)
                .blur(radius: blurRadius)
            }
            .scrollDisabled(scrollDisabled)
            .onScrollPhaseChange { _, newPhase, context in
                scrollState = (newPhase, context)
            }
            .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y
            }, action: { _, newValue in
                if newValue <= 0 {
                    index == 0 ? (windowState.isOffsetAtTop = true) : (isOffsetAtTop = true)
                } else if newValue > 0 {
                    index == 0 ? (windowState.isOffsetAtTop = false) : (isOffsetAtTop = false)
                }
            })
            
            Button() {
                layerManager.pushLayer()
                layerManager.layers[index].state = .collapsed(height: collapsedHeight)
                layerManager.updateOffsets(collapsedOffset: collapsedOffset)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .frame(minWidth: width, minHeight: height)
        .frame(height: layer.state.dynamicHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(layer.isCollapsed ? colors[index % colors.count] : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .offset(y: layer.offsetY)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    guard index > 0 else { return }
                    let dragY = value.translation.height

                    // Slowly expabds the previous layer if there is one if the user drags down.
                    if isOffsetAtTop, dragY > 0 {
                        if !scrollDisabled {
                            scrollDisabled = true
                        }
                        if case .collapsed = layerManager.layers[index - 1].state {
                            let newHeight = collapsedHeight + dragY / 2

                            layerManager.layers[index - 1].state = .collapsed(height: newHeight)

                            withAnimation(.spring()) {
                                blurRadius = dragY / 100
                                scale = 1 - dragY / 1000
                            }
                        }
                    }
                }
                .onEnded { value in
                    guard index > 0 else { return }
                    let verticalDrag = value.translation.height
                    let verticalVelocity = value.velocity.height
                    let velocityThreshold: CGFloat = 500
                    scrollDisabled = false

                    if isOffsetAtTop, verticalDrag > 0 {
                        if case .collapsed = layerManager.layers[index - 1].state,
                           verticalDrag > heightCenter || verticalVelocity > velocityThreshold
                        {
                            // On a successful drag down, collapse the previous layer & animate the current.
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .expanded
                                layerManager.layers[index - 1].offsetY = 0 // Reset the previous view offset.
                                layerManager.layers[index].offsetY = height // Slide the current view down.
                            } completion: {
                                layerManager.popLayer(at: index)
                            }
                        } else {
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .collapsed(height: collapsedHeight)
                                blurRadius = 0
                                scale = 1
                            }
                        }
                    }
                }
        )
        .animation(.spring(), value: layer.isCollapsed)
    }
}

class Reply: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let text: String?
    let avatarURL: String
    var children: [Reply] = []

    init(username: String, text: String? = nil, avatarURL: String, children: [Reply] = []) {
        self.username = username
        self.text = text
        self.avatarURL = avatarURL
        self.children = children
    }

    static func == (lhs: Reply, rhs: Reply) -> Bool {
        return lhs.id == rhs.id
    }
}

// Sample comments with nesting
let sampleComments: [Reply] = [
    Reply(
        username: "johnnyD",
        text: "fr this is facts",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "janey",
                text: "omg thank u johnny lol we gotta talk about this more",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "mikez",
                        text: "idk janey i feel like it’s different tho can u explain more",
                        avatarURL: "https://picsum.photos/200/200",
                        children: [
                            Reply(
                                username: "janey",
                                text: "mike i get u but it’s like the bigger picture yk",
                                avatarURL: "https://picsum.photos/200/200",
                                children: [
                                    Reply(
                                        username: "sarah_123",
                                        text: "yeah janey got a point tho",
                                        avatarURL: "https://picsum.photos/200/200",
                                        children: [
                                            Reply(
                                                username: "johnnyD",
                                                text: "lowkey agree with sarah",
                                                avatarURL: "https://picsum.photos/200/200",
                                                children: [
                                                    Reply(
                                                        username: "mikez",
                                                        text: "ok i see it now",
                                                        avatarURL: "https://picsum.photos/200/200",
                                                        children: [
                                                            Reply(
                                                                username: "janey",
                                                                text: "glad we’re all on the same page now lol",
                                                                avatarURL: "https://picsum.photos/200/200"
                                                            )
                                                        ]
                                                    )
                                                ]
                                            )
                                        ]
                                    )
                                ]
                            )
                        ]
                    )
                ]
            ),
            Reply(
                username: "sarah_123",
                text: "i think it’s a bit more complicated than that",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "johnnyD",
                        text: "yeah i see what u mean",
                        avatarURL: "https://picsum.photos/200/200",
                        children: [
                            Reply(
                                username: "sarah_123",
                                text: "exactly johnny",
                                avatarURL: "https://picsum.photos/200/200"
                            )
                        ]
                    ),
                    Reply(
                        username: "janey",
                        text: "i disagree",
                        avatarURL: "https://picsum.photos/200/200"
                    ),
                    Reply(
                        username: "mikez",
                        text: "i don’t think it’s that simple",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            )
        ]
    ),
    Reply(
        username: "sarah_123",
        text: "i think it’s a bit more complicated than that",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "johnnyD",
                text: "yeah i see what u mean",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "sarah_123",
                        text: "exactly johnny",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            ),
            Reply(
                username: "janey",
                text: "i disagree",
                avatarURL: "https://picsum.photos/200/200"
            ),
            Reply(
                username: "mikez",
                text: "i don’t think it’s that simple",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "mike",
        text: "i don’t think it’s that simple",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "sarah_123",
                text: "mike i think you’re missing the point",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "mike",
                        text: "sarah i get it but it’s not that black and white",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            ),
            Reply(
                username: "johnnyD",
                text: "mike i think you’re right",
                avatarURL: "https://picsum.photos/200/200"
            ),
            Reply(
                username: "janey",
                text: "mike i think you’re wrong",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "johnnyD",
        text: "mike i think you’re right",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "janey",
        text: "mike i think you’re wrong",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "mike",
        text: "i don’t think it’s that simple",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "sarah_123",
                text: "mike i think you’re missing the point",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "mike",
                        text: "sarah i get it but it’s not that black and white",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            ),
            Reply(
                username: "johnnyD",
                text: "mike i think you’re right",
                avatarURL: "https://picsum.photos/200/200"
            ),
            Reply(
                username: "janey",
                text: "mike i think you’re wrong",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "alex_b",
        text: "I disagree with you, janey.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "jessica_w",
        text: "mike, you’re oversimplifying this.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "daniel_r",
        text: "Interesting point, but I don’t see it that way.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "emma_k",
        text: "janey has a point, mike.",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "mike",
                text: "I hear you, but I still think I’m right.",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "george",
        text: "This conversation is going in circles.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "john_doe",
        text: "sarah_123, I agree with you.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "jane_d",
        text: "I think everyone’s missing the main point here.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "tina_l",
        text: "Can we all just agree to disagree?",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "matt_w",
        text: "mike, you’re totally missing the bigger picture.",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "mike",
                text: "That’s fair, matt. But consider this...",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "lucy_h",
        text: "This is getting way too heated.",
        avatarURL: "https://picsum.photos/200/200"
    )
]

struct BottomCurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the curve
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width / 2))

        // Draw the rounded corner curve to the right center
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct TopBottomCurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the top curve to the right
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + rect.width / 2),
                          control: CGPoint(x: rect.maxX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the bottom curve
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.width / 2))

        // Draw the bottom curve to the left
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}

struct LoopPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0.95*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.75*height))
        path.addCurve(to: CGPoint(x: 0.20953*width, y: 0.26027*height), control1: CGPoint(x: 0.5*width, y: 0.51429*height), control2: CGPoint(x: 0.36032*width, y: 0.26027*height))
        path.addCurve(to: CGPoint(x: 0.03333*width, y: 0.50961*height), control1: CGPoint(x: 0.05874*width, y: 0.26027*height), control2: CGPoint(x: 0.03333*width, y: 0.41697*height))
        path.addCurve(to: CGPoint(x: 0.20956*width, y: 0.74652*height), control1: CGPoint(x: 0.03333*width, y: 0.60226*height), control2: CGPoint(x: 0.06435*width, y: 0.74652*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.25*height), control1: CGPoint(x: 0.3771*width, y: 0.74652*height), control2: CGPoint(x: 0.5*width, y: 0.50267*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.05*height))
        return path
    }
}

func tricornOffset(for index: Int, radius: CGFloat = 12) -> CGSize {
    switch index {
    case 0: // Top Center
        return CGSize(width: 0, height: -radius)
    case 1: // Bottom Left
        return CGSize(width: -radius*cos(.pi / 6), height: radius*sin(.pi / 6))
    case 2: // Bottom Right
        return CGSize(width: radius*cos(.pi / 6), height: radius*sin(.pi / 6))
    default:
        return .zero
    }
}
