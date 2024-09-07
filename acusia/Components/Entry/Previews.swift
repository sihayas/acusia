//
//  entrypreview.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//

import BigUIPaging
import MusicKit
import SwiftUI

struct EntryPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                CardPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/6a/0c/2e/6a0c2e21-e649-0ea3-07ff-b2a66daf7ac5/24UMGIM24898.rgb.jpg/600x600bb.jpg", name: "In A Landscape", artistName: "Max Richter", text: "Strikes a pleasing equilibrium between music to admire and music to enjoy")

                ReactionPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/df/8d/f1/df8df1a2-34b2-9588-b059-ff81d1525dd5/656605144269.jpg/600x600bb.jpg", name: "Stranger In The Alps", artistName: "Phoebe Bridgers", text: "dont get the big deal with this one tbh")

                WispPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/76/96/d1/7696d110-c929-4908-8fa1-30aad2511c55/00602567485872.rgb.jpg/600x600bb.jpg", name: "High as Hope", artistName: "Florence + The Machine", text: "florance is a queen. i can go on and on about what she means to me but i wont")
            }
        }
    }
}

struct CardPreview: View {
    @Namespace private var namespace
    @State private var selection: Int = 1
    let imageUrl: String
    let name: String
    let artistName: String
    let text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("juna")
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.leading)
                .padding(.leading, 64)
                .padding(.bottom, -2)

            HStack(alignment: .bottom, spacing: 8) {
                AvatarView(size: 36, imageURL: "https://i.pinimg.com/474x/98/85/c1/9885c1779846521a9e7aad8de50ac015.jpg")
                    .zIndex(1)

                // Card stack
                PageView(selection: $selection) {
                    ForEach([1, 2], id: \.self) { index in
                        if index == 1 {
                            RoundedRectangle(cornerRadius: 0, style: .continuous)
                                .foregroundStyle(.thickMaterial)
                                .background(
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        Rectangle()
                                    }
                                )
                                .mask(
                                    ArtimaskPath()
                                        .stroke(.white.opacity(0.5), lineWidth: 1)
                                        .fill(.black)
                                )
                                .overlay(alignment: .topLeading) {
                                    ZStack(alignment: .bottomTrailing) {
                                        VStack(alignment: .leading) {
                                            Text(text)
                                                .foregroundColor(.white)
                                                .font(.system(size: 15, weight: .semibold))
                                                .multilineTextAlignment(.leading)

                                            Spacer()

                                            VStack(alignment: .leading) {
                                                Text(name)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                                    .lineLimit(1)

                                                Text(artistName)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                    .lineLimit(1)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding(20)

                                        HeartPath()
                                            .fill(.black)
                                            .frame(width: 32, height: 30)
                                            .frame(width: 32, height: 32)
                                            .padding(8)
                                            .shadow(radius: 4)
                                            .rotationEffect(.degrees(8))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                        } else {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .background(.clear)
                                .overlay(alignment: .bottom) {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                    } placeholder: {
                                        Rectangle()
                                    }
                                }
                        }
                    }
                }
                .pageViewStyle(.customCardDeck)
                .pageViewCardCornerRadius(32.0)
                .pageViewCardShadow(.visible)
                .frame(width: 204, height: 280)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if !sampleComments.isEmpty {
                HStack(spacing: 4) {
                    VStack {
                        BottomCurvePath()
                            .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(maxWidth: 36, maxHeight: 18)

                        Spacer()
                    }
                    .frame(width: 36, height: 36)

                    ZStack {
                        ForEach(0 ..< 3) { index in
                            AvatarView(size: 14, imageURL: "https://picsum.photos/200/300")
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
                                .offset(tricornOffset(for: index, radius: 10))
                        }
                    }
                    .frame(width: 36, height: 36)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}

struct ReactionPreview: View {
    @Namespace private var namespace
    @State private var selection: Int = 1
    let imageUrl: String
    let name: String
    let artistName: String
    let text: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HStack(alignment: .bottom) {
                AvatarView(size: 36, imageURL: "https://i.pinimg.com/474x/98/85/c1/9885c1779846521a9e7aad8de50ac015.jpg")

                HStack {
                    // Audiowave image in white
                    Image(systemName: "waveform")
                        .symbolEffect(.variableColor.iterative, options: .repeating)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.secondary)

                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                    } placeholder: {
                        Rectangle()
                    }
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .frame(width: 32, height: 32)

                    VStack(alignment: .leading) {
                        Text(artistName)
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                        Text(name)
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                    }
                    .lineLimit(1) // Restrict to a single line
                    .truncationMode(.tail) // Truncate if it's too long

                    Spacer()

                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }

            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.pink)
                    .frame(width: 5, height: 5)
                    .offset(x: -8, y: 6)
                Circle()
                    .fill(Color.pink)
                    .frame(width: 12, height: 12)
                    .offset(x: 2, y: 2)
                Circle()
                    .fill(Color.pink)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    )
            }
            .padding(.bottom, 36)
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 24)
    }
}

struct WispPreview: View {
    @Namespace private var namespace
    @State private var selection: Int = 1
    let imageUrl: String
    let name: String
    let artistName: String
    let text: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HStack(alignment: .bottom) {
                AvatarView(size: 36, imageURL: "https://i.pinimg.com/474x/98/85/c1/9885c1779846521a9e7aad8de50ac015.jpg")

                HStack {
                    // Audiowave image in white
                    Image(systemName: "waveform")
                        .symbolEffect(.variableColor.iterative, options: .repeating)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.secondary)

                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                    } placeholder: {
                        Rectangle()
                    }
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .frame(width: 32, height: 32)

                    VStack(alignment: .leading) {
                        Text(artistName)
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                        Text(name)
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                    }
                    .lineLimit(1) // Restrict to a single line
                    .truncationMode(.tail) // Truncate if it's too long

                    Spacer()

                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }

            ZStack(alignment: .bottomLeading) {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 5, height: 5)
                    .offset(x: 8, y: 6)
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 12, height: 12)
                    .offset(x: -2, y: 2)
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.bottom, 40)
            .padding(.leading, 28)
            .padding(.trailing, 64)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 24)
    }
}

#Preview {
    EntryPreview()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

struct CustomArtwork {
    let urlFormat: String
    let maximumWidth: Int
    let maximumHeight: Int
    let backgroundColor: CGColor
    let primaryTextColor: CGColor
    let secondaryTextColor: CGColor
    let tertiaryTextColor: CGColor
    let quaternaryTextColor: CGColor
}
