//
//  PhotosScrollView.swift
//  iOS18PhotosAppUI
//
//  Created by Xiaofu666 on 2024/7/21.


import SwiftUI

struct TopScrollView: View {
    let size: CGSize
    let safeArea: EdgeInsets
    @Environment(ShareData.self) private var shareData
    @State private var position: ScrollPosition  = .init()
    
    var body: some View {
        let screenHeight = size.height + safeArea.top + safeArea.bottom
        let minimizedHeight = screenHeight - safeArea.top
        
        VStack() {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 4), count: 2), spacing: 4) {
                    ForEach(1...50, id: \.self) { _ in
                        Rectangle()
                            .fill(.gray)
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
            } action: { oldValue, newValue in
                shareData.topScrollViewValue = newValue
            }
            .frame(width: size.width)
            .id(3)
            .clipped()
        }
        .frame(height: screenHeight)
        .frame(height: screenHeight - minimizedHeight + minimizedHeight * shareData.gestureProgress, alignment: .bottom)
        .border(Color.green, width: 1)
        .overlay(alignment: .bottom) {
            BottomBarView {
                Task {
                    try? await Task.sleep(for: .seconds(0.13))
                    withAnimation(.snappy(duration: 0.6, extraBounce: 0)) {
                        shareData.gestureProgress = 0
                        shareData.isExpanded = false
                    }
                }
            }
        }
    }
}
