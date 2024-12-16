import SwiftUI

struct Home: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState

    @State var scrollOffset: CGFloat = 0

    @State var isTopExpanded = false
    @State var isBottomExpanded = false
    @State var dragState: DragState = .none

    enum DragState {
        case none
        case began
        case draggingUp
        case draggingDown
        case ended
    }

    @State var scrollAnchor: UnitPoint = .bottom
    @State var scrollFrameAnchor: Alignment = .bottom
    @State var scrollFrameHeight: CGFloat? = nil
    @State var bottomFrameHeight: CGFloat? = nil
    @State var topFrameHeight: CGFloat? = nil

    var body: some View {
        GeometryReader { proxy in
            let screenHeight = proxy.size.height
            let minTopHeight = screenHeight * 0.6
            let minBottomHeight = screenHeight * 0.4

            ScrollViewReader { _ in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing: 4), count: 2), spacing: 4) {
                            ForEach(1 ... 50, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 120)
                            }
                        }
                        .border(.red, width: 2)
                        .frame(
                            height: topFrameHeight,
                            alignment: .bottom
                        ) 
                        
                        LazyVGrid(columns: Array(repeating: GridItem(spacing: 4), count: 2), spacing: 4) {
                            ForEach(1 ... 50, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(.systemGray4))
                                    .frame(height: 120)
                            }
                        }
                        .border(.red, width: 2)
                        .frame(
                            height: bottomFrameHeight,
                            alignment: .top
                        )
                    }
                    .frame(
                        maxHeight: scrollFrameHeight,
                        alignment: scrollFrameAnchor
                    )
                }
                .defaultScrollAnchor(scrollAnchor)
                .scrollBounceBehavior(.basedOnSize)
                .onScrollGeometryChange(for: CGFloat.self) { proxy in
                    proxy.contentOffset.y
                } action: { _, newValue in
                    scrollOffset = newValue
                }
                .border(.blue.opacity(1))
                .gesture(
                    CustomGesture(isEnabled: true) { gesture in
                        let state = gesture.state
                        let translation = gesture.translation(in: gesture.view).y

                        switch state {
                        case .began:
                            /// Crop the frame to prevent bounce overscroll and prepare for the drag.
                            dragState = .began
                            topFrameHeight = minTopHeight
                            bottomFrameHeight = minBottomHeight
                            scrollFrameHeight = screenHeight
                        case .changed:
                            dragState = translation > 0 ? .draggingDown : .draggingUp

                            if dragState == .draggingDown {
                                scrollAnchor = .bottom
                                scrollFrameAnchor = .bottom
                                scrollFrameHeight = nil
                                topFrameHeight = nil
                            }

                            if dragState == .draggingUp {
                                scrollAnchor = .top
                                scrollFrameAnchor = .top
                                scrollFrameHeight = nil
                                bottomFrameHeight = nil
                            }
                        case .ended:
                            if dragState == .draggingDown {
                                isTopExpanded = true
                                scrollAnchor = .bottom
                                scrollFrameAnchor = .bottom
                                scrollFrameHeight = nil
                            }

                            if dragState == .draggingUp {
                                isBottomExpanded = true
                                scrollAnchor = .top
                                scrollFrameAnchor = .top
                                scrollFrameHeight = nil
                            }

                            dragState = .ended
                        default:
                            dragState = .none
                        }
                    }
                )
                .overlay(alignment: .bottom) {
                    LinearGradientMask(gradientColors: [.black.opacity(0.5), Color.clear])
                        .frame(height: safeAreaInsets.bottom * 2)
                        .scaleEffect(x: 1, y: -1)
                }
                .overlay(alignment: .top) {
                    LinearBlurView(radius: 2, gradientColors: [.clear, .black])
                        .scaleEffect(x: 1, y: -1)
                        .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top)
                }
            }
            .onAppear {
                scrollFrameHeight = screenHeight
                topFrameHeight = minTopHeight
                bottomFrameHeight = minBottomHeight
            }
        }
    }
}

struct HomePastView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var position: ScrollPosition = .init()

    let size: CGSize
    var body: some View {
        let screenHeight = size.height
        let minimizedHeight = screenHeight * 0.4

        ScrollView(.vertical) {}
            // .scrollDisabled(!homeState.collapseScrollDisabled)
            .defaultScrollAnchor(.bottom)
            .scrollPosition($position)
            .onScrollGeometryChange(for: CGFloat.self, of: {
                /// Inits the topScrollOffset at 0, to the difference between the contentOffset and the containerSize.
                $0.contentOffset.y - $0.contentSize.height + $0.containerSize.height
            }, action: { _, _ in
                // if oldValue != newValue {
                //     if newValue >= 0 {
                //         homeState.topScrollOffset = 0
                //         print("TopScrollOffset: \(homeState.topScrollOffset)")
                //     } else {
                //         homeState.topScrollOffset = newValue
                //     }
                // }
            })
            .frame(height: screenHeight, alignment: .top)
    }
}

// if not expand and greater than 0, enable it. if expand and less than 1 disable it.
// .offset(y: -minimizedHeight + gestureProgress)

/// User's Past?
// VStack(spacing: 12) {
//     /// Main Feed
//     BiomePreviewView(biome: Biome(entities: biomePreviewOne))
//     // BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
//     // BiomePreviewView(biome: Biome(entities: biomePreviewThree))
// }
