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
        VStack(alignment: .leading, spacing: 12) {
            // Sound attachment
            HStack(alignment: .top, spacing: 12) {
                VStack {
                    AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                        image
                            .resizable()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: .black.opacity(0.7), radius: 16, x: 0, y: 4)
                    } placeholder: {
                        ProgressView()
                    }
                }
                .padding(4)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                VStack(alignment: .leading) {
                    Text(entry.sound.appleData?.name ?? "")
                        .lineLimit(1)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.secondary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color(UIColor.systemGray6), in: Capsule())
                }
                .padding(.vertical, 8)
                
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
                    .offset(x: -6, y: 4)
                
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
                    FlameTap(isTapped: entry.isFlameTapped, count: entry.flameCount)
                        .offset(x: -20, y: -26)
                    HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                        .offset(x: 12, y: -26)
                },
                alignment: .topTrailing
            )
        }
        .padding([.bottom, .leading], 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
