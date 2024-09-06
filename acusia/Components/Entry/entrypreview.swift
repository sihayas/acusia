//
//  entrypreview.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//

import MusicKit
import SwiftUI

struct EntryPreview: View {
    var body: some View {
        let imageUrl = "https://is1-ssl.mzstatic.com/image/thumb/Music4/v4/6a/54/13/6a54138c-e296-88d5-0449-96647323b873/cover.jpg/600x600bb.jpg"

        ScrollView {
            VStack(spacing: 24) {
                // Entry
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .foregroundStyle(.thinMaterial)
                        .background(
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Rectangle()
                            }
                        )
                        .overlay(alignment: .topLeading) {
                            VStack(alignment: .leading) {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 8)
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("Women")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .lineLimit(1)
                                    
                                    Text("Public Strain")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .lineLimit(1)
                                }
                                .padding([.horizontal, .bottom], 12)
                            }
                        }
                        .frame(width: 224, height: 280, alignment: .top)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.leading, 48)

                    // Avatar, Text, and Thread Line
                    HStack(alignment: .bottom, spacing: 12) {
                        AvatarView(size: 36, imageURL: "https://i.pinimg.com/474x/98/85/c1/9885c1779846521a9e7aad8de50ac015.jpg")

                        ZStack(alignment: .bottomLeading) {
                            Circle()

                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 6, height: 6)
                                .offset(x: -8, y: 3)

                            Circle()

                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 12, height: 12)

                            Text("It's such an abstract and off-kilter sound that I could hardly see having produced widespread ripples at the time of its release. ")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .transition(.blurReplace)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(UIColor.systemGray6),
                                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 3)
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
}

struct DraggableSoundView: View {
    let imageUrl: String

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .foregroundStyle(.thickMaterial)
            .background(
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                } placeholder: {
                    Rectangle()
                }
            )
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                    } placeholder: {
                        Rectangle()
                    }
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 8)
                    .offset(y: dragOffset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation {
                                    dragOffset = .zero
                                }
                            }
                    )

                    Spacer()

                    VStack(alignment: .leading) {
                        Text("Women")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .lineLimit(1)

                        Text("Public Strain")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .lineLimit(1)
                    }
                    .padding([.horizontal, .bottom], 12)
                }
            }
            .frame(width: 224, height: 280, alignment: .top)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
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
