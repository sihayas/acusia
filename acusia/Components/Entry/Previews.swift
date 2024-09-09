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
                CardPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/26/24/07/2624075e-51b9-60a4-bc11-93bbdde0f36c/103097.jpg/600x600bb.jpg", name: "Why Bonnie?", artistName: "Wish on the Bone", text: "‘Wish On The Bone’ is out now ⛓️‍💥🌱 I’m truly at a loss for words — so much love, change, & passion went into this album. My hope is that you can feel some of that love when listening to these songs & that it gives you strength to take on the day. Or at least, bop along🦋", avatar: "https://i.pinimg.com/474x/8d/7f/a7/8d7fa70fa5ec7919737e3868afa96675.jpg")

                CardPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/f7/8c/19/f78c1951-ced5-fea6-251b-50914d96fd62/00196922948305_Cover.jpg/600x600bb.jpg", name: "Charm", artistName: "Clairo", text: "It's a shame because this album is almost pretty good, but it's so flat and uninteresting that I can't recommend it. The whole album is just begging to be sampled, and that feels like a compliment but really it just means that it's inoffensive enough that somebody could rap over it and it wouldn't clash. The mix is sort of nice, but the high end is completely lacking, and I feel like they were going for a warm fuzzy vibe but it doesn't quite hit that either. The vocals are so understated that they may as well not be there at all. Maybe it would be a better album if they weren't.", avatar: "https://i.pinimg.com/474x/2d/49/3c/2d493ca53e6fee2a0a9017bc2cdb22f3.jpg")

                CardPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/ab/9d/c9/ab9dc97e-4147-e677-c7f3-05afd5562c23/cover.jpg/600x600bb.jpg", name: "megacity1000", artistName: "1tbsp", text: "new album ‘megacity1000’ is like taking a tour through not just a variety of cities, but a collection of experiences that all produce specific feelings within you", avatar: "https://i.pinimg.com/474x/2d/49/3c/2d493ca53e6fee2a0a9017bc2cdb22f3.jpg")

                WispPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/df/8d/f1/df8df1a2-34b2-9588-b059-ff81d1525dd5/656605144269.jpg/600x600bb.jpg", name: "Stranger In The Alps", artistName: "Phoebe Bridgers", text: "", type: "reaction")

                WispPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/76/96/d1/7696d110-c929-4908-8fa1-30aad2511c55/00602567485872.rgb.jpg/600x600bb.jpg", name: "High as Hope", artistName: "Florence + The Machine", text: "florance is a queen. i can go on and on about what she means to me but i wont", type: "no")
            }
        }
    }
}

struct CardPreview: View {
    @Namespace private var namespace
    @State private var selection: Int = 1
    @State private var showPopover = false
    @State private var showPopoverAnimate = false
    @State private var showEmojiTextField = false

    let imageUrl: String
    let name: String
    let artistName: String
    let text: String
    let avatar: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("username")
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.leading)
                .padding(.leading, 64)
                .padding(.bottom, -2)

            HStack(alignment: .bottom, spacing: 8) {
                AvatarView(size: 36, imageURL: avatar)
                    .zIndex(1)

                // Card stack
                PageView(selection: $selection) {
                    ForEach([1, 2], id: \.self) { index in
                        if index == 1 {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(.ultraThickMaterial)
                                .background(
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                    } placeholder: {
                                        Rectangle()
                                    }
                                )
                                .overlay {
                                    ZStack(alignment: .bottomTrailing) {
                                        if !showPopover {
                                            VStack {
                                                Text(text)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .padding([.horizontal, .top], 20)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .mask(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        .init(color: .black, location: 0),
                                                        .init(color: .black, location: 0.75),
                                                        .init(color: .clear, location: 0.825)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                                .frame(height: .infinity)
                                            )
                                        }

                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(artistName)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                Text(name)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                    .lineLimit(1)
                                            }

                                            Spacer()

                                            HeartPath()
                                                .fill(.pink)
                                                .frame(width: 28, height: 26)
                                                .frame(height: 28)
                                                .shadow(radius: 4)
                                                .rotationEffect(.degrees(8))
                                        }
                                        .padding(20)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        // Trigger the emoji text field to appear or take focus
                                        showEmojiTextField = true
                                    } label: {
                                        Label("Open Emoji Keyboard", systemImage: "keyboard")
                                    }
                                }
                                .popover(isPresented: $showPopover, attachmentAnchor: .point(.topLeading), arrowEdge: .bottom) {
                                    ScrollView {
                                        Text(text)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .font(.system(size: 15, weight: .regular))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(width: 272)
                                    .presentationCompactAdaptation(.popover)
                                    .presentationBackground(.ultraThinMaterial)
                                }
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        showPopoverAnimate.toggle()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        showPopover = showPopoverAnimate
                                    }
                                }
                                .onChange(of: showPopover) { _, value in
                                    if !value {
                                        withAnimation(.spring()) {
                                            showPopoverAnimate = false
                                        }
                                    }
                                }
                                .frame(height: showPopoverAnimate ? 68 : 280)
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

struct WispPreview: View {
    @Namespace private var namespace
    let imageUrl: String
    let name: String
    let artistName: String
    let text: String
    let type: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("juna")
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.leading)
                .padding(.leading, 40)
                .padding(.bottom, -2)

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
                        .lineLimit(1)
                        .truncationMode(.tail)

                        Spacer()
                    }
                }

                if type == "reaction" {
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
                } else {
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
                            .contextMenu {
                                Button {
                                    // Add this item to a list of favorites.
                                } label: {
                                    Label("Open Emoji Keyboard", systemImage: "keyboard")
                                }
                            }
                    }
                    .padding(.bottom, 40)
                    .padding(.leading, 28)
                    .padding(.trailing, 64)
                }
            }

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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 24)
    }
}

#Preview {
    EntryPreview()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}
