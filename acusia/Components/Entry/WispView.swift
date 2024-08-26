//
//  WispView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import SwiftUI

struct WispView: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Sound attachment
            HStack(spacing: 12) {
                VStack {
                    AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                        image
                            .resizable()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // Text bubble
            ZStack(alignment: .bottomLeading) {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 12, height: 12)
                    .offset(x: 0, y: 0)
                
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 6, height: 6)
                    .offset(x: -8, y: 2)
                
                Text(entry.text)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .overlay(
                ZStack {
                    HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                        .offset(x: 12, y: -26)
                },
                alignment: .topTrailing
            )
        }
        .padding([.leading], 12)
        .padding([.bottom], 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
