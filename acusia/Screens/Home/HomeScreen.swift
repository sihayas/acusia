import SwiftUI

class HomeState: ObservableObject {
    static let shared = HomeState()

    init() {}

    @Published var isExpanded: Bool = false

    @Published var mainScrollValue: CGFloat = 0
    @Published var topScrollViewValue: CGFloat = 0

    @Published var canPullDown: Bool = false
    @Published var canPullUp: Bool = false

    @Published var gestureProgress: CGFloat = 0
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
    }
}
