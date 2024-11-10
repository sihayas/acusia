import SwiftUI

class HomeState: ObservableObject {
    // Singleton instance
    static let shared = HomeState()

    // Prevent external initialization
    init() {}

    // Your shared properties go here
    @Published var isExpanded: Bool = false

    // ScrollView Properties
    @Published var mainScrollValue: CGFloat = 0
    @Published var topScrollViewValue: CGFloat = 0

    // These properties will be used to evaluate the drag conditions,
    // whether the scroll view can either be pulled up or down for expanding/minimizing the photos scrollview
    @Published var canPullDown: Bool = false
    @Published var canPullUp: Bool = false

    @Published var gestureProgress: CGFloat = 0

    @Published var showReplies: Bool = false
    @Published var repliesOffset: CGFloat = 0
}

struct Home: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var shareData: HomeState

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                /// User's Past?
                // PastView(size: size)

                /// Main Feed
                VStack(spacing: 32) {
                    BiomeView(biome: Biome(entities: biomeOne))
                    BiomeView(biome: Biome(entities: biomeTwo))
                }
                .padding(.top, safeAreaInsets.top)
                .padding(.bottom, safeAreaInsets.bottom * 3)
            }
        }
        .scrollClipDisabled(true)
        .frame(width: windowState.size.width, height: windowState.size.height)
        .overlay(alignment: .top) {
            VStack {
                VariableBlurView(radius: 1, mask: Image(.gradient))
                    .scaleEffect(x: 1, y: -1)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top * 1.5)
                
                Spacer()
            }
        }
    }
}
