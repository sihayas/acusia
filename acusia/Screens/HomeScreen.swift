import SwiftUI

enum DragState {
    case dragging
    case draggedUp
    case draggedDown
    case idle
}

struct Home: View {
    @Environment(\.viewSize) private var viewSize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState
    @GestureState var gestureState: Bool = false

    @State var topContentSize: CGSize = .zero

    @State var isExpanded = false
    @State var dragState: DragState = .idle
    @State var scrollOffset: CGFloat = 0
    @State var topScrollOffset: CGFloat = 0
    @State var allowTopHitTest = true
    @State var allowBottomHitTest = false

    @State var bottomOffset: CGFloat = 0
    @State var topOffset: CGFloat = 0

    let maxTranslation: CGFloat = 124

    var body: some View {
        GeometryReader { _ in
            let offset: CGFloat = viewSize.height * 0.4

            ScrollView {
                VStack(spacing: 0) {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 4)], spacing: 4) {
                            ForEach(1 ... 50, id: \.self) { _ in
                                Rectangle()
                                    .fill(allowTopHitTest ? .green.opacity(0.5) : .red.opacity(0.5))
                                    .frame(height: 120)
                            }
                        }
                        .offset(y: topOffset)
                    }
                    .onScrollGeometryChange(for: CGFloat.self, of: {
                        /// This will be zero when the content is placed at the bottom
                        $0.contentOffset.y - $0.contentSize.height + $0.containerSize.height
                    }, action: { _, newValue in
                        topScrollOffset = newValue
                        // print(topScrollOffset)
                    })
                    .frame(height: viewSize.height)
                    .defaultScrollAnchor(.bottom)
                    .scrollClipDisabled()
                    .allowsHitTesting(allowTopHitTest)
                    .border(.blue, width: 2)

                    VStack(spacing: 4) {
                        ForEach(1 ... 12, id: \.self) { _ in
                            Rectangle()
                                .fill(allowBottomHitTest ? .green.opacity(0.5) : .red.opacity(0.5))
                                .frame(height: 120)
                        }
                    }
                    .allowsHitTesting(allowBottomHitTest)
                    .border(.red, width: 2)
                    .offset(y: bottomOffset)
                }
            } 
            .onScrollGeometryChange(for: CGFloat.self, of: {
                /// This will be zero when the content is placed at the bottom
                $0.contentOffset.y
            }, action: { oldValue, newValue in

                guard oldValue != newValue else { return }

                if newValue <= 0 {
                    allowTopHitTest = true
                    allowBottomHitTest = false
                }

                scrollOffset = newValue

                // print(scrollOffset)
            })
            .defaultScrollAnchor(.top)
            .scrollClipDisabled()
            .frame(height: viewSize.height, alignment: .top)
            // .clipped()
            .onChange(of: gestureState) { _, newValue in
                /// As soon as the user starts dragging, we check if the relevant scrollview is at the minimum offset.
                if newValue, (isExpanded && topScrollOffset >= 0) || (!isExpanded && scrollOffset <= 0) {
                    dragState = .dragging
                    allowBottomHitTest = false
                    allowTopHitTest = true
                    // print("Drag Enabled \(isExpanded ? "While Expanded" : "While Not Expanded")")
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($gestureState) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        guard dragState != .idle else {
                            return
                        }

                        let translation = value.translation.height

                        if dragState == .dragging, translation > 0 {
                            dragState = .draggedDown
                            allowBottomHitTest = false
                            allowTopHitTest = true
                        }

                        if dragState == .dragging, translation < 0 {
                            dragState = .draggedUp
                            allowTopHitTest = false
                            allowBottomHitTest = true
                        }

                        if !isExpanded, dragState == .draggedDown {
                            print("Not expanded, and dragging down = expand.")
                            let limited = min(translation, maxTranslation)
                            let ratio = limited / maxTranslation
                            topOffset = -offset * (1 - ratio)
                            bottomOffset = -offset * (1 - ratio)
                        }

                        if isExpanded, dragState == .draggedUp {
                            print("Expanded, and dragging up = collapse.")
                            let limited = min(-translation, maxTranslation)
                            let ratio = limited / maxTranslation
                            topOffset = -offset * ratio
                            bottomOffset = -offset * ratio
                        }
                    }
                    .onEnded { value in
                        guard dragState != .idle else {
                            return
                        }

                        let translation = value.translation.height

                        if !isExpanded, dragState == .draggedDown {
                            isExpanded = true
                        }

                        if isExpanded, dragState == .draggedUp {
                            isExpanded = false
                        }

                        dragState = .idle
                    }
            )
            .onAppear {
                topOffset = -offset
                bottomOffset = -offset
            }
            .scaleEffect(0.5)
        }
    }
}

// .overlay(alignment: .bottom) {
//     LinearGradientMask(gradientColors: [.black.opacity(0.5), Color.clear])
//         .frame(height: safeAreaInsets.bottom * 2)
//         .scaleEffect(x: 1, y: -1)
// }
// .overlay(alignment: .top) {
//     LinearBlurView(radius: 2, gradientColors: [.clear, .black])
//         .scaleEffect(x: 1, y: -1)
//         .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top)
// }
/// User's Past?
// VStack(spacing: 12) {
//     /// Main Feed
//     BiomePreviewView(biome: Biome(entities: biomePreviewOne))
//     // BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
//     // BiomePreviewView(biome: Biome(entities: biomePreviewThree))
// }
