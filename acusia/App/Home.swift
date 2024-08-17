import SwiftUI

@Observable
class ShareData {
    // This is true when the TopScrollView is Expanded
    var isExpanded: Bool = false
    
    // MainScrollView Properties
    var mainScrollValue: CGFloat = 0
    var topScrollViewValue: CGFloat = 0
    
    // Selected category for the photos
    var selectedCategory: String = "年"
    
    // These properties will be used to evaluate the drag conditions,
    // whether the scroll view can either be pulled up or down for expanding/minimizing the photos scrollview
    var canPullUp: Bool = false
    var canPullDown: Bool = false
    
    var gestureProgress: CGFloat = 0
}

struct Home: View {
    let size: CGSize
    let safeArea: EdgeInsets
    let shareData = ShareData()
    @StateObject private var auth = Auth.shared
    
    @Binding var homePath: NavigationPath

    // State to track current visible view
    @State private var currentView: String = "mainView"

    var body: some View {
        let sidebarWidth = size.width * 0.9
        
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            TopScrollView(size: size, safeArea: safeArea)
                            
                            UserScreen(homePath: $homePath, initialUserData: nil, userResult: UserResult(id: "3f6a2219-8ea1-4ff1-9057-6578ae3252af", username: "decoherence", image: "https://i.pinimg.com/474x/45/8a/ce/458ace69027303098cccb23e3a43e524.jpg"))
                                .border(Color.purple, width: 2)
                                .frame(minHeight: size.height)
                                .offset(y: shareData.gestureProgress * 30)
                            
                            FeedScreen(userId: auth.user?.id ?? "")
                        }
                    }
                    .onScrollGeometryChange(for: CGFloat.self) { proxy in
                        proxy.contentOffset.y
                    } action: { oldValue, newValue in
                        shareData.mainScrollValue = newValue
                    }
                    .scrollDisabled(shareData.isExpanded)
                    .environment(shareData)
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                let translation = value.translation.height * 0.1 // Friction
                                let draggingUp = translation < 0
                                let draggingDown = translation > 0
                                
                                if draggingDown && shareData.mainScrollValue <= 0 && !shareData.isExpanded {
                                    shareData.canPullDown = true
                                    let progress = max(min(translation / (size.height + safeArea.top + safeArea.bottom) * 0.2, 1.0), 0.0)
                                    shareData.gestureProgress = progress
                                } else if draggingUp && shareData.topScrollViewValue >= 0 && shareData.isExpanded {
                                    shareData.canPullUp = true
                                    let progress = max(min(-translation / (size.height + safeArea.top + safeArea.bottom) * 0.2, 1.0), 0.0)
                                    shareData.gestureProgress = 1 - progress
                                } else {
                                    // Conditions not met for progress calculation
                                }
                            }
                            .onEnded { value in
                                withAnimation(.snappy(duration: 0.6, extraBounce: 0)) {
                                    if shareData.canPullDown && value.translation.height > 0 && !shareData.isExpanded {
                                        shareData.isExpanded = true
                                        shareData.gestureProgress = 1
                                    } else if shareData.canPullUp && value.translation.height < 0 && shareData.isExpanded {
                                        shareData.isExpanded = false
                                        shareData.gestureProgress = 0
                                    }
                                }
                                shareData.canPullDown = false
                                shareData.canPullUp = false
                            }
                    )
                    .frame(width: size.width)
                    .id("mainView")
                    
                    
                    VStack {
                        Text("Notifications")
                            .font(.largeTitle)
                            .padding()
                        Spacer()
                    }
                    .frame(width: sidebarWidth)
                    .background(Color.black)
                    .border(Color.cyan, width: 1)
                    .id("sidebar")
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .onScrollTargetVisibilityChange(idType: String.self) { visibleTargets in
                if let visibleTarget = visibleTargets.first, visibleTarget != currentView {
                    currentView = visibleTarget
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(.black)
        .ignoresSafeArea()
    }
}

#Preview {
    AcusiaAppView()
}
