import SwiftUI

class HomeState: ObservableObject {
    static let shared = HomeState()

    init() {}

    @Published var isExpanded: Bool = false

    @Published var mainScrollOffset: CGFloat = 0
    @Published var topScrollOffset: CGFloat = 0

    @Published var canPullDown: Bool = false
    @Published var canPullUp: Bool = false

    @Published var gestureProgress: CGFloat = 0
}

struct Home: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState
    @EnvironmentObject private var homeState: HomeState

    var body: some View {
        GeometryReader { proxy in
            let minimizedHeight = proxy.size.height * 0.4

            ScrollView(.vertical) {
                /// User's Past?
                VStack(spacing: 12) {
                    HomePastView(size: proxy.size)
                        .border(.blue, width: 1)

                    // HStack(alignment: .firstTextBaseline, spacing: 4) {
                    //     Text("Atlas")
                    //         .font(.subheadline)
                    //         .fontWeight(.semibold)

                    //     Text("alpha*")
                    //         .font(.subheadline)

                    //     Spacer()
                    // }
                    // .frame(maxWidth: .infinity)
                    // .safeAreaPadding(.all)

                    /// Main Feed
                    BiomePreviewView(biome: Biome(entities: biomePreviewOne))
                    BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
                    BiomePreviewView(biome: Biome(entities: biomePreviewThree))
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { proxy in
                proxy.contentOffset.y
            } action: { _, newValue in
                homeState.mainScrollOffset = newValue
                // print("mainScrollOffset: \(homeState.mainScrollOffset)")
            }
            /// Disable scrolling the main Feed when Home is expanded.
            .scrollDisabled(homeState.isExpanded)
            .scrollClipDisabled(true)
            .gesture(
                CustomGesture(isEnabled: true) { gesture in
                    let state = gesture.state
                    let translation = gesture.translation(in: gesture.view).y
                    let isDragging = state == .began || state == .changed

                    if state == .began {
                        homeState.canPullDown = translation > 0 && homeState.mainScrollOffset == 0
                        homeState.canPullUp = translation < 0 && homeState.topScrollOffset == 0
                    }
                    
                    // print("translation: \(translation)")

                    if isDragging {
                        if homeState.canPullDown && !homeState.isExpanded {
                            let progress = max(min(translation / minimizedHeight, 1.0), 0.0)
                            homeState.gestureProgress = progress
                        }
                        if homeState.canPullUp && homeState.isExpanded {
                            let progress = max(min(-translation / minimizedHeight, 1.0), 0.0)
                            homeState.gestureProgress = 1 - progress
                        }
                    } else {
                        withAnimation(.smooth) {
                            if homeState.canPullDown && translation > 0 && !homeState.isExpanded {
                                homeState.isExpanded = true
                                homeState.gestureProgress = 1
                            }
                            if homeState.canPullUp && translation < 0 && homeState.isExpanded {
                                homeState.isExpanded = false
                                homeState.gestureProgress = 0
                            }
                        }
                    }
                }
            )
            .overlay(alignment: .bottom) {
                LinearGradientMask(gradientColors: [.black.opacity(0.5), Color.clear])
                    .frame(height: safeAreaInsets.bottom * 2)
                    .scaleEffect(x: 1, y: -1)
            }
            // .border(.red)
            .overlay(alignment: .top) {
                LinearBlurView(radius: 2, gradientColors: [.clear, .black])
                    .scaleEffect(x: 1, y: -1)
                    .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top)
            }
            .contentMargins(.bottom, safeAreaInsets.bottom * 3)
            .onChange(of: homeState.gestureProgress) { oV, value in
                print("gestureProgress: \(value)")
            }
        }
    }
}

struct HomePastView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var homeState: HomeState
    @State private var position: ScrollPosition = .init()

    let size: CGSize
    var body: some View {
        let screenHeight = size.height
        let minimizedHeight = screenHeight * 0.4

        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 4), count: 2), spacing: 4) {
                ForEach(1 ... 50, id: \.self) { _ in
                    Rectangle()
                        .fill(.ultraThickMaterial)
                        .frame(height: 120)
                }
            }
        }
        .offset(y: homeState.canPullUp ? homeState.topScrollOffset : 0)
        .scrollPosition($position)
        .onScrollGeometryChange(for: CGFloat.self, of: {
            /// Inits the topScrollOffset at 0, to the difference between the contentOffset and the containerSize.
            $0.contentOffset.y - $0.contentSize.height + $0.containerSize.height
        }, action: { _, newValue in
            homeState.topScrollOffset = newValue
            print("topScrollOffset: \(homeState.topScrollOffset)")
        })
        /// Disable scrolling through past messages when Home is not expanded.
        .scrollDisabled(homeState.topScrollOffset <= 0 && !homeState.isExpanded)
        .defaultScrollAnchor(.bottom)
        .scrollIndicators(.hidden)
        .frame(height: screenHeight)
        .frame(height: screenHeight - minimizedHeight + minimizedHeight * homeState.gestureProgress, alignment: .bottom)
    }
}
