import SwiftUI

class ShareData: ObservableObject {
    // This is true when the TopScrollView is Expanded
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
    let size: CGSize
    let safeArea: EdgeInsets
    @EnvironmentObject private var shareData: ShareData
    @StateObject private var auth = Auth.shared
    
    @Binding var homePath: NavigationPath

    // State to track current visible view
    @State private var currentView: String = "mainView"

    var body: some View {
        let sidebarWidth = size.width * 0.9
        
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    // Main Feed + User + User History View
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            HomePastView(size: size, safeArea: safeArea)
                            
                            HomeWallView(homePath: $homePath, initialUserData: nil, userResult: UserResult(id: "3f6a2219-8ea1-4ff1-9057-6578ae3252af", username: "decoherence", image: "https://i.pinimg.com/474x/45/8a/ce/458ace69027303098cccb23e3a43e524.jpg"))
                                .frame(minHeight: size.height)
                                .offset(y: shareData.gestureProgress * 30)
                            
                            HomeFeedView(userId: auth.user?.id ?? "")
                                .padding(.top, safeArea.bottom + 40)
                                .padding(.bottom, safeArea.bottom)
                        }
                    }
                    .scrollDisabled(shareData.isExpanded)
                    .opacity(shareData.showReplies ? 0.25 : 1)
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
                    .frame(width: size.width)
                    .id("mainView")
                    
                    // Notifications View
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
                // Haptic feedback when switching to notifications.
                if let visibleTarget = visibleTargets.first, visibleTarget != currentView {
                    currentView = visibleTarget
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay(
                ZStack(alignment: .top) {
                    VariableBlurView(radius: 16, mask: Image(.gradient))
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(x: shareData.showReplies ? 1 : 0,
                                     y: shareData.showReplies ? 1 : 0, anchor: .bottom)
                        .animation(.spring(duration: 0.7), value: shareData.showReplies)

                    if shareData.showReplies {
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                CommentsListView(replies: sampleComments)
                                    .padding(.top, shareData.repliesOffset)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .frame(width: geometry.size.width,
                       height: geometry.size.height,
                       alignment: .topLeading)
                ,
                alignment: .top
            )
            .overlay(alignment: .bottom) {
                FeedBarView(safeArea: safeArea)
            }
        }
        .background(.black)
        .ignoresSafeArea()
    }
}

#Preview {
    AcusiaAppView()
}
