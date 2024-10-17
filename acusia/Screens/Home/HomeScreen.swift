import SwiftUI

class HomeState: ObservableObject {
    // Singleton instance
    static let shared = HomeState()

    // Prevent external initialization
    private init() {}

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
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var shareData: HomeState
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    let size: CGSize
    @Binding var homePath: NavigationPath

    var body: some View {
        // Main Feed + User + User History View
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                PastView(size: size, safeArea: safeAreaInsets)

                GridView(homePath: $homePath,
                          id: "3f6a2219-8ea1-4ff1-9057-6578ae3252af",
                        username: "decoherence",
                        image: "https://i.pinimg.com/474x/45/8a/ce/458ace69027303098cccb23e3a43e524.jpg",
                         size: size)

                FeedView(size: size)
                    .padding(.top, safeAreaInsets.bottom + 40)
            }
        }
        .scrollDisabled(shareData.isExpanded)
        // Search Sheet
        .sheet(isPresented: $windowState.showSearchSheet) {
            IndexSheet()
        }
//                    .onScrollGeometryChange(for: CGFloat.self) { proxy in
//                        proxy.contentOffset.y
//                    } action: { oldValue, newValue in
//                        shareData.mainScrollValue = newValue
//                        print("Main Scroll Value: \(newValue)")
//                    }
//                    .simultaneousGesture(
//                        DragGesture()
//                            .onChanged { value in
//                                let translation = value.translation.height * 0.1 // Friction
//                                let draggingUp = translation < 0
//                                let draggingDown = translation > 0
//
//                                if draggingDown && shareData.mainScrollValue <= 0 && !shareData.isExpanded {
//                                    shareData.canPullDown = true
//                                    let progress = max(min(translation / (size.height + safeArea.top + safeArea.bottom) * 0.2, 1.0), 0.0)
//                                    shareData.gestureProgress = progress
//                                } else if draggingUp && shareData.topScrollViewValue >= 0 && shareData.isExpanded {
//                                    shareData.canPullUp = true
//                                    let progress = max(min(-translation / (size.height + safeArea.top + safeArea.bottom) * 0.2, 1.0), 0.0)
//                                    shareData.gestureProgress = 1 - progress
//                                } else {
//                                    // Conditions not met for progress calculation
//                                }
//                            }
//                            .onEnded { value in
//                                withAnimation(.snappy(duration: 0.6, extraBounce: 0)) {
//                                    if shareData.canPullDown && value.translation.height > 0 && !shareData.isExpanded {
//                                        shareData.isExpanded = true
//                                        shareData.gestureProgress = 1
//                                    } else if shareData.canPullUp && value.translation.height < 0 && shareData.isExpanded {
//                                        shareData.isExpanded = false
//                                        shareData.gestureProgress = 0
//                                    }
//                                }
//                                shareData.canPullDown = false
//                                shareData.canPullUp = false
//                            }
//                    )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
