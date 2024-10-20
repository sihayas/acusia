import SwiftUI

struct PastView: View {
    let size: CGSize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var shareData: HomeState
    @State private var position: ScrollPosition = .init()

    var body: some View {
        let screenHeight = size.height + safeAreaInsets.top + safeAreaInsets.bottom
        let minimizedHeight = screenHeight - safeAreaInsets.top

        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 4), count: 2), spacing: 4) {
                ForEach(1 ... 50, id: \.self) { _ in
                    Rectangle()
                        .fill(.black)
                        .opacity(0.5)
                        .frame(height: 120)
                }
            }
        }
        .defaultScrollAnchor(.bottom)
        .scrollDisabled(!shareData.isExpanded)
        .scrollPosition($position)
        .scrollClipDisabled()
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.y - proxy.contentSize.height + proxy.containerSize.height
        } action: { _, newValue in
            shareData.topScrollViewValue = newValue
        }
        .frame(width: size.width)
        .id(3)
        .clipped()
        .frame(height: screenHeight)
        .frame(height: screenHeight - minimizedHeight + minimizedHeight * shareData.gestureProgress, alignment: .bottom)
    }
}
