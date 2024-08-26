//
//  CustomPagingIndicatorView.swift
//  iOS18PhotosAppUI
//
//  Created by Xiaofu666 on 2024/7/21.
//

import SwiftUI

struct FeedBarView: View {
    @EnvironmentObject private var shareData: ShareData
    @Namespace private var animation
    
    let safeArea: EdgeInsets
    @State private var isRevealed: Bool = true

    var body: some View {
        // Normalize progress between 0 and 1
        let progress = min(max(shareData.mainScrollValue / 840, 0), 1)
        
        HStack(spacing: 10) {
            Button {} label: {
                Image(systemName: "chevron.up")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 42, height: 42)
                    .background(
                        ZStack {
                            // Blur effect
                            Color.clear.background(.thinMaterial)
                                .clipShape(Circle())
                            Color.white.opacity(0.1)
                                .clipShape(Circle())
                        }
                    )
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 32)
            }
            .frame(height: 42)
            .background(
                ZStack {
                    // Blur effect
                    Color.clear.background(.thinMaterial)
                        .clipShape(Capsule())
                    Color.white.opacity(0.1)
                        .clipShape(Capsule())
                }
            )
            
            Spacer()

            Button {} label: {
                Image(systemName: "moon.stars.fill")
                    .frame(width: 42, height: 42)
                    .background(
                        ZStack {
                            // Blur effect
                            Color.clear.background(.thinMaterial)
                                .clipShape(Circle())
                            Color.white.opacity(0.1)
                                .clipShape(Circle())
                        }
                    )
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, safeArea.bottom)
        .padding(.trailing, safeArea.bottom)
        .padding(.leading, safeArea.bottom)
        .frame(maxWidth: .infinity)
        .scaleEffect(isRevealed ? 1 : 0, anchor: .top)
        .blur(radius: isRevealed ? 0 : 10)
        .offset(y: isRevealed ? 0 : -8)
        .onChange(of: progress) { newValue in
            if newValue == 1 {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    isRevealed = true
                }
            }
        }
    }
}
