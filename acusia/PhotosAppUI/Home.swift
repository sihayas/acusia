//
//  Home.swift
//  iOS18PhotosAppUI
//
//  Created by Xiaofu666 on 2024/7/20.
//

import SwiftUI


@Observable
class ShareData {
    // This is true when the Photos Grid ScrollView is Expanded
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
    
    var body: some View {
        let minimizedHeight = (size.height + safeArea.top + safeArea.bottom) * 0.2
        
        ZStack {
            UserScreen(initialUserData: nil, userResult: UserResult(id: "3f6a2219-8ea1-4ff1-9057-6578ae3252af", username: "decoherence", image: "https://i.pinimg.com/474x/45/8a/ce/458ace69027303098cccb23e3a43e524.jpg"))

            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    TopScrollView(size: size, safeArea: safeArea)
                    
                    MiddleScrollView(size: size, safeArea: safeArea)
                        .offset(y: shareData.gestureProgress * 30)
                    
                    
                    BottomScrollView(size: size, safeArea: safeArea)
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { proxy in
                proxy.contentOffset.y
            } action: { oldValue, newValue in
                shareData.mainScrollValue = newValue
            }
            /// Disabling the Main ScrollView Interaction, When the Photos Grid is Expanded
            .scrollDisabled(shareData.isExpanded)
            .environment(shareData)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        // Apply friction by scaling down the translation
                        let translation = value.translation.height * 0.1 // Friction
                        
                        let draggingUp = translation < 0
                        let draggingDown = translation > 0
                        
                        if draggingDown && shareData.mainScrollValue <= 0 && !shareData.isExpanded {
                            shareData.canPullDown = true
                            
                            let progress = max(min(translation / minimizedHeight, 1.0), 0.0)
                            shareData.gestureProgress = progress

                        } else if draggingUp && shareData.topScrollViewValue >= 0 && shareData.isExpanded {
                            shareData.canPullUp = true
                            let progress = max(min(-translation / minimizedHeight, 1.0), 0.0)
                            shareData.gestureProgress = 1 - progress

                        } else {
                            print("Conditions not met for progress calculation.")
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
                        // Reset pull-up/pull-down flags
                        shareData.canPullDown = false
                        shareData.canPullUp = false
                    }
            )
        }
        .background(.black)
    }
}


#Preview {
    AcusiaAppView()
}
