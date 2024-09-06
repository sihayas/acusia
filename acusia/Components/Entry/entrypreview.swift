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
            VStack(spacing: 64) {
                // Avatar, Text, and Thread Line
                HStack(alignment: .bottom, spacing: 4) {
                    AvatarView(size: 36, imageURL: "https://i.pinimg.com/474x/98/85/c1/9885c1779846521a9e7aad8de50ac015.jpg")

                    CardPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/6a/0c/2e/6a0c2e21-e649-0ea3-07ff-b2a66daf7ac5/24UMGIM24898.rgb.jpg/600x600bb.jpg", name: "In A Landscape", artistName: "Max Richter", text: "VISCERAL!!!")
                        .frame(width: 204, height: 280)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 24)

                // Avatar, Text, and Thread Line
                HStack(alignment: .bottom, spacing: 4) {
                    AvatarView(size: 36, imageURL: "https://i.pinimg.com/474x/9d/8e/db/9d8edbcad90d577b5856725c2867eeed.jpg")

                    CardPreview(imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/ba/1e/05/ba1e058e-5637-e53c-563c-f5b9a1a6c344/20UM1IM18331.rgb.jpg/600x600bb.jpg", name: "Whole Lotta Red", artistName: "Playboi Carti", text: "dont get the big deal with this one tbh")
                        .frame(width: 204, height: 280)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 24)
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
        VStack {
            // Use ForEach with a collection of identifiable data
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                            .foregroundStyle(
                                .ultraThickMaterial
                            )
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
                                VStack(alignment: .leading) {
                                    Text(text)
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .semibold))
                                        .multilineTextAlignment(.leading)

                                    Spacer()

                                    VStack(alignment: .leading) {
                                        Text(artistName)
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 11, weight: .regular))

                                        Text(name)
                                            .foregroundColor(.white)
                                            .font(.system(size: 11, weight: .regular))
                                    }
                                }
                                .padding(20)
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
                                        .clipShape(RoundedRectangle(cornerRadius: 32))
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
        }
    }

    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
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
