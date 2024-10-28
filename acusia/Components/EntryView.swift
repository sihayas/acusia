//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

struct WispView: View {
    @EnvironmentObject private var windowState: WindowState
    let entry: EntryModel

    @State private var scale: CGFloat = 1

    var body: some View {
        // Outer Container
        VStack(alignment: .leading, spacing: 0) {
            // Inner (Replies)
            VStack(spacing: 8) {
                /// Root
                HStack(alignment: .bottom, spacing: 8) {
                    AvatarView(size: 40, imageURL: entry.userImage)
                        .overlay(alignment: .topLeading) {
                            ZStack {
                                AsyncImage(url: URL(string: entry.imageUrl)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .padding(2)
                                .background(Circle().fill(Color(UIColor.black)))
                            }
                            .frame(width: 56, height: 56)
                            .background(.black, in: SoundBubbleWithTail())
                            .offset(x: 0, y: -48)
                            .shadow(color: .black.opacity(1.0), radius: 4)
                        }
                        .zIndex(1)

                    ReplyBubble(text: entry.text, username: entry.username, artist: entry.artistName, album: entry.name)

                    Spacer(minLength: 0)
                }

                /// First Reply (Direct)
                HStack(alignment: .bottom, spacing: 8) {
                    VStack {
                        Capsule()
                            .frame(width: 4)
                            .foregroundColor(Color(UIColor.systemGray6))

                        AvatarView(size: 40, imageURL: "https://i.pinimg.com/736x/41/6d/33/416d33a61850d826a2c4781d78e2341f.jpg")
                    }
                    .frame(maxHeight: .infinity)

                    ReplyBubble(text: "autolux?", username: "ben")

                    Spacer(minLength: 8)
                }

                /// Second Reply (Indirect)
                VStack(spacing: 8) {
                    // Parent
                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .frame(width: 4, height: 8)
                                .foregroundColor(Color(UIColor.systemGray6))

                            LoopPath()
                                .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 32, height: 24)

                            AvatarView(size: 24, imageURL: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif")
                                .frame(width: 40)
                        }
                        .frame(maxHeight: .infinity)

                        ReplyOutlineBubble(text: "No and tbh vultures 1 clears both🦅", username: "qwertyyy")

                        Spacer(minLength: 8)
                    }

                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .frame(width: 4)
                                .foregroundColor(Color(UIColor.systemGray6))

                            AvatarView(size: 40, imageURL: "https://i.pinimg.com/474x/ca/a6/c7/caa6c70c24e6705894a36755fdba4fca.jpg")
                        }
                        .frame(maxHeight: .infinity)

                        ReplyBubble(text: "in what world lmao", username: "august")

                        Spacer(minLength: 8)
                    }
                    .frame(maxHeight: .infinity) // Important!
                }

                /// Third Reply
                VStack(spacing: 8) {
                    // Parent
                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .frame(width: 4, height: 8)
                                .foregroundColor(Color(UIColor.systemGray6))

                            LoopPath()
                                .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 32, height: 24)

                            AvatarView(size: 24, imageURL: "https://i.pinimg.com/736x/c9/00/97/c90097f2cca68e76fc40831ba96dc9a5.jpg")
                                .frame(width: 40)
                        }
                        .frame(maxHeight: .infinity)

                        ReplyOutlineBubble(text: "don’t piss me off WLR was the blueprint", username: "lancey_fouxx")

                        Spacer(minLength: 8)
                    }

                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .frame(width: 4)
                                .foregroundColor(Color(UIColor.systemGray6))

                            AvatarView(size: 40, imageURL: "https://i.pinimg.com/474x/fd/f1/21/fdf12119ecb977a68bc10d185dbb2523.jpg")
                        }
                        .frame(maxHeight: .infinity)

                        ReplyBubble(text: "Im a fan of both but wlr is wayyyyyyyy better, my fav album", username: "zack+")

                        Spacer(minLength: 8)
                    }
                    .frame(maxHeight: .infinity) // Important!
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(UIColor.black))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
    }
}

struct ReplyBubble: View {
    let text: String
    let username: String
    var artist: String?
    var album: String?

    @State private var rippleTrigger = false
    @State private var velocity: CGFloat = 0
    @State private var origin: CGPoint = .zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6), in: WispBubbleWithTail(scale: 1))
            .clipShape(WispBubbleWithTail(scale: 1))
            .foregroundStyle(.secondary)
            .padding(.bottom, 3)
            .overlay(alignment: .topLeading) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(username)
                        .foregroundColor(.secondary)
                        .font(.system(size: 13, weight: .regular))

                    if let artist = artist, let album = album {
                        Text("·")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, weight: .bold))

                        VStack(alignment: .leading) {
                            Text("\(artist), \(album)")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                        }
                    }
                }
                .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }

            BlipView(size: CGSize(width: 60, height: 60))
                .alignmentGuide(VerticalAlignment.top) { d in d.height / 1.6 }
                .alignmentGuide(HorizontalAlignment.trailing) { d in d.width * 0.7 }
        }
    }
}

struct ReplyOutlineBubble: View {
    let text: String
    let username: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(text)
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                WispBubbleWithTail(scale: 1)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                Text(username)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                    .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 6)
        }
    }
}

// if !sampleComments.isEmpty {
//     GeometryReader { geometry in
//         VStack {
//             Spacer()
//             LeadingCenterToBottomCenterPath()
//                 .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
//                 .frame(height: geometry.size.height / 2)
//         }
//     }
//     .frame(maxWidth: 36)
// }
