//
//  WispView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import SwiftUI

struct WispView: View {
    let entry: APIEntry
    let animateReplySheet: Bool
    
    var body: some View {
        let imageUrl = entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"
        
        HStack(alignment: .bottom, spacing: 0) {
            AvatarView(size: animateReplySheet ? 24 : 32, imageURL: entry.author.image)
            
            VStack(alignment: .leading, spacing: 8) {
                // Sound attachment
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .frame(width: animateReplySheet ? 24 : 64, height: animateReplySheet ? 24 : 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .frame(width: 64, height: 64)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(entry.sound.appleData?.name ?? "")
                            .font(.system(size: animateReplySheet ? 11 : 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(entry.sound.appleData?.artistName ?? "")
                            .font(.system(size: animateReplySheet ? 11 : 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(animateReplySheet ? 12 : 0)
                .background(.black,
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(animateReplySheet ? 0.1 : 0), lineWidth: 1)
                )
                .padding(.trailing, 40)
                
                // Text bubble
                ZStack(alignment: .bottomLeading) {
                    Circle()
                        .stroke(animateReplySheet ? .white.opacity(0.1): .clear , lineWidth: 1)
                        .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                        .frame(width: 12, height: 12)
                        .offset(x: 0, y: 0)
                    
                    Circle()
                        .stroke(animateReplySheet ? .white.opacity(0.1): .clear , lineWidth: 1)
                        .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                        .frame(width: 6, height: 6)
                        .offset(x: -8, y: 2)
                    
                    VStack {
                        Text(entry.text)
                            .foregroundColor(.white)
                            .font(.system(size: animateReplySheet ? 11 : 15, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .transition(.blurReplace)
                            .lineLimit(animateReplySheet ? 4 : nil)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(animateReplySheet ? .black : Color(UIColor.systemGray6),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(UIColor.systemGray6).opacity(animateReplySheet ? 1 : 0), lineWidth: 1)
                    )
                    .overlay(
                        ZStack {
                            HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                                .offset(x: 12, y: -26)
                                .scaleEffect(animateReplySheet ? 0.75 : 1)
                        },
                        alignment: .topTrailing
                    )
                }
                
            }
            .padding([.leading], 12)
            .padding([.bottom], 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}
