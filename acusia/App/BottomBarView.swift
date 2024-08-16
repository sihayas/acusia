//
//  CustomPagingIndicatorView.swift
//  iOS18PhotosAppUI
//
//  Created by Xiaofu666 on 2024/7/21.
//

import SwiftUI

struct BottomBarView: View {
    var onClose: () -> ()
    @Environment(ShareData.self) private var shareData
    @Namespace private var animation
    
    var body: some View {
        let progress = shareData.gestureProgress
        
        HStack(spacing: 10) {
            Button {
                
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .frame(width: 35, height: 35)
                    .background(.ultraThinMaterial, in: .circle)
            }
            
            HStack(spacing: 0) {
                // add icons here
            }
            .background(.ultraThinMaterial, in: .capsule)
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .frame(width: 35, height: 35)
                    .background(.ultraThinMaterial, in: .circle)
                    .contentShape(.circle)
            }
        }
        .foregroundStyle(.primary)
            .fixedSize()
            .blur(radius: 1 - progress * 5)
            .opacity(progress)
            .offset(y: -4 - progress * 30)
    }
}
