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
            HStack(alignment: .firstTextBaseline) {
                Text("Atlas")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("closed alpha*")

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .safeAreaPadding(.all)

            /// Main Feed
            VStack(spacing: 12) {
                BiomePreviewView(biome: Biome(entities: biomePreviewOne))
                BiomePreviewView(biome: Biome(entities: biomePreviewTwo)) 
                BiomePreviewView(biome: Biome(entities: biomePreviewThree))
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled(true)
        .padding(.top, safeAreaInsets.top)
        .overlay(alignment: .bottom) {
            LinearGradientMask(gradientColors: [.black.opacity(0.5), Color.clear])
                .frame(height: safeAreaInsets.bottom * 2)
                .scaleEffect(x: 1, y: -1)
        }
        .contentMargins(.bottom, safeAreaInsets.bottom * 3)
    }
}
