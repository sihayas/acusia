import SwiftUI

struct Home: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState
    
    @State var hasAppeared: Bool = false

    enum DragState {
        case none
        case began
        case draggingUp
        case draggingDown
        case ended
    }

    @GestureState var gestureState: Bool = false
    @State var scrollOffset: CGFloat = 0
    @State var enableDrag = true
    @State var dragState: DragState = .none
    @State var topFrameHeight: CGFloat? = nil
    @State var bottomFrameHeight: CGFloat? = nil

    var body: some View {
        GeometryReader { proxy in
            let screenHeight = proxy.size.height
            let minTopHeight = screenHeight

            ScrollViewReader { scrollProxy in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        VStack(spacing: 4) {
                            ForEach(1 ... 50, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 120)
                            }
                        }
                        .frame(
                            height: nil,
                            alignment: .bottom
                        )
                        .border(.purple, width: 2)
                        .clipped()

                        VStack(spacing: 4) {
                            ForEach(1 ... 12, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(.systemGray2))
                                    .frame(height: 120)
                            }
                        }
                        .frame(
                            height: nil,
                            alignment: .top
                        )
                        .border(.red, width: 2)
                    }
                    .frame(height: topFrameHeight, alignment: .bottom)
                    .clipped()
                }
                .defaultScrollAnchor(.bottom)
                .scrollClipDisabled()
                .border(.yellow, width: 2)
                // .scrollDisabled(true)
                .onScrollGeometryChange(for: CGFloat.self, of: {
                    /// This will be zero when the content is placed at the bottom
                    $0.contentOffset.y - $0.contentSize.height + $0.containerSize.height
                }, action: { _, newValue in
                    scrollOffset = newValue
                    print(scrollOffset)
                })
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .updating($gestureState) { _, state, _ in
                            guard enableDrag else { return }

                            state = true
                        }
                        .onChanged { value in
                            guard enableDrag else { return }
                            let translation = value.translation.height
 
                            if translation > 0 { 
                                topFrameHeight = minTopHeight + screenHeight + translation
                                // bottomFrameHeight = screenHeight - translation
                            }
                        }
                        .onEnded { _ in
                            topFrameHeight = screenHeight * 40
                                // scrollProxy.scrollTo("spacer", anchor: .top)
                            dragState = .ended
                        }
                )
                .scaleEffect(0.25)
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
                .onAppear {
                    topFrameHeight = minTopHeight + screenHeight
                    bottomFrameHeight = screenHeight
                }
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
