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
}

struct Layer: Identifiable {
    let id = UUID()
    var state: LayerState = .expanded
    var offsetY: CGFloat = 0 // For animating off-screen
    
    var isCollapsed: Bool {
        state.isCollapsed
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

struct RepliesSheet: View {
    @EnvironmentObject private var windowState: WindowState
    @StateObject private var layerManager = LayerManager()

    var size: CGSize

    var body: some View {
        let heightCenter = size.height / 2
        let collapsedHeight = size.height * 0.1
        let collapsedOffset = size.height * 0.05
        
        ZStack(alignment: .top) {
            ForEach(Array(layerManager.layers.enumerated()), id: \.element.id) { index, replyItem in
                LayerView(
                    layerManager: layerManager,
                    sampleComments: sampleComments,
                    width: size.width,
                    height: size.height,
                    heightCenter: heightCenter,
                    collapsedHeight: collapsedHeight,
                    replyItem: replyItem,
                    index: index,
                    onPushNewView: {
                        withAnimation(.spring()) {
                            layerManager.layers[index].state = .collapsed(height: collapsedHeight)
                            layerManager.pushLayer()
                        }
                    }
                )
                .offset(y: calculateOffset(for: index, offset: collapsedOffset) + replyItem.offsetY)
                .zIndex(Double(layerManager.layers.count - index))
            }
        }
        .allowsHitTesting(windowState.isSplitFull)
        .onReceive(layerManager.$layers) { layers in
            windowState.isLayered = layers.count > 1
        }
    }

    private func calculateOffset(for index: Int, offset: CGFloat) -> CGFloat {
        layerManager.layers[(index + 1)...].reduce(0) { total, layer in
            layer.isCollapsed ? total - offset : total
        }
    }
}

struct LayerView: View {
    @EnvironmentObject private var windowState: WindowState
    @ObservedObject var layerManager: LayerManager
    
    @State private var isOffsetAtTop = true
    @State private var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    
    let sampleComments: [Reply]
    let width: CGFloat
    let height: CGFloat
    let heightCenter: CGFloat
    let collapsedHeight: CGFloat
    let replyItem: Layer
    let index: Int
    let onPushNewView: () -> Void

    var body: some View {
        let isCollapsed = replyItem.isCollapsed
        let dynamicHeight = replyItem.state.dynamicHeight

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(sampleComments) { reply in
                    ReplyView(reply: reply)
                }
            }
        }
        .onScrollPhaseChange { _, newPhase, context in
            scrollState = (newPhase, context)
        }
        .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
            geometry.contentOffset.y
        }, action: { _, newValue in
            let atTop = newValue <= 0
            if index == 0 {
                windowState.isOffsetAtTop = atTop
            } else {
                isOffsetAtTop = atTop
            }
        })
        .frame(minWidth: width, minHeight: height)
        .frame(height: dynamicHeight, alignment: .top)
        .clipped()
        .allowsHitTesting(!isCollapsed)
        .overlay(
            Button(action: onPushNewView) {
                Text(isCollapsed ? "Collapsed" : "Push New View")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(isCollapsed ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
        )
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCollapsed ? Color.gray.opacity(0.3) : Color.clear)
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    guard index > 0, isOffsetAtTop else { return }
                    let dragY = value.translation.height
                    if case .collapsed = layerManager.layers[index - 1].state {
                        layerManager.layers[index - 1].state = .collapsed(height: collapsedHeight + dragY / 2)
                    }
                }
                .onEnded { value in
                    guard index > 0, isOffsetAtTop else { return }
                    let dragY = value.translation.height
                    if case .collapsed = layerManager.layers[index - 1].state, dragY > heightCenter {
                        withAnimation(.spring()) {
                            layerManager.layers[index - 1].state = .expanded
                            layerManager.layers[index].offsetY = height
                        } completion: {
                            layerManager.popLayer(at: index)
                        }
                    } else {
                        withAnimation(.spring()) {
                            layerManager.layers[index - 1].state = .collapsed(height: collapsedHeight)
                        }
                    }
                }
        )
        .animation(.spring(), value: isCollapsed)
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
