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
    @EnvironmentObject private var windowState: UIState
    @EnvironmentObject private var shareData: HomeState

    var body: some View {
        ScrollView {
            /// User's Past?
            // PastView(size: size)
            HStack {
                Text("Atlas")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .safeAreaPadding(.horizontal)
                    .padding(.top, safeAreaInsets.top)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)

            /// Main Feed
            VStack(spacing: 16) {
                BiomePreviewView(biome: Biome(entities: biomeSpotlightOne))
                BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
            }
            .padding(.horizontal, 8)
            
            Spacer()
                .frame(minHeight: safeAreaInsets.bottom * 3)
        }
        .scrollClipDisabled(true)
    }
}
