//
//  ReplyView.swift
//  acusia
//
//  Created by decoherence on 10/1/24.
//

import SwiftUI

struct ReplyView: View {
    let reply: Reply

    var body: some View {
        VStack(alignment: .leading) {
            // Comment
            HStack(alignment: .bottom, spacing: 0) {
                AvatarView(size: 32, imageURL: reply.avatarURL)

                // Text bubble
                VStack(alignment: .leading, spacing: 4) {
                    Text(reply.username)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)

                    ZStack(alignment: .bottomLeading) {
                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 12, height: 12)
                            .offset(x: 0, y: 2)

                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 6, height: 6)
                            .offset(x: -6, y: 4)

                        Text(reply.text ?? "")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding([.leading], 8)
                    .padding([.bottom], 4)
                    .overlay(
                        ZStack {
                            HeartTapSmall(isTapped: false, count: 0)
                                .offset(x: 12, y: -14)
                        },
                        alignment: .topTrailing
                    )
                }
            }

            // Children
            if !reply.children.isEmpty {
                Capsule()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 3)
                    .frame(width: 32)
                // Expand thread capsule
                HStack(spacing: -4) {
                    LoopPath()
                        .stroke(Color(UIColor.systemGray6),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 30, height: 20)
                        .frame(width: 32)
                        .transition(.scale)
                    Text("4 threads")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
