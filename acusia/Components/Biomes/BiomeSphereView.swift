//
//  BiomeSphereView.swift
//  acusia
//
//  Created by decoherence on 12/10/24.
//

import SwiftUI

struct BiomePreviewSphereView: View {
    @EnvironmentObject private var windowState: UIState

    let biome: Biome

    @Namespace var animation
    @State private var showSheet: Bool = false

    var body: some View {
        let photos = biome.entities[1].getPhotoAttachments()

        VStack {
            ZStack {
                Circle()
                    .background(
                        CollageLayout {
                            ForEach(userDevs.shuffled().prefix(3), id: \.id) { _, user in
                                GeometryReader { _ in
                                    Circle()
                                        .background(
                                            AsyncImage(url: URL(string: user.imageUrl)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                Rectangle()
                                                    .foregroundColor(.gray.opacity(0.3))
                                            }
                                        )
                                        .foregroundStyle(.clear)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(16)
                    )
                    .foregroundStyle(.thickMaterial)
                    .matchedTransitionSource(id: "hi", in: animation)

                CollageLayout {
                    ForEach(userDevs.shuffled().prefix(3), id: \.id) { index, user in
                        GeometryReader { proxy in
                            Circle()
                                .background(
                                    AsyncImage(url: URL(string: user.imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Rectangle()
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                )
                                .foregroundStyle(.clear)
                                .clipShape(Circle())
                                .overlay(alignment: .bottom) {
                                    VStack {
                                        if index == 0 {
                                            if let photo = photos.first {
                                                AsyncImage(url: URL(string: photo.url)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(
                                                            width: proxy.size.width * 2,
                                                            height: proxy.size.width * 2
                                                        )
                                                        .clipped()
                                                } placeholder: {
                                                    Rectangle()
                                                        .foregroundColor(.gray.opacity(0.3))
                                                }
                                            } else {
                                                Text(biome.entities[0].text)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 12)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(4)
                                            }
                                        }
                                    }
                                    .background(.ultraThinMaterial, in: PreviewBubbleWithTailShape(scale: 1.0))
                                    .foregroundStyle(.secondary)
                                    .clipShape(PreviewBubbleWithTailShape(scale: 1.0))
                                    .shadow(radius: 4)
                                    .frame(
                                        width: proxy.size.width * 3,
                                        height: proxy.size.height * 3,
                                        alignment: .bottom
                                    )
                                    .fixedSize(horizontal: true, vertical: false)
                                    .offset(
                                        x: proxy.size.width * 0.5,
                                        y: -proxy.size.height * 0.75
                                    )
                                }
                        }
                    }
                }
                .padding(16)
                .scaleEffect(showSheet ? 0 : 1.0)
                .animation(.smooth, value: showSheet)
            }
            .aspectRatio(1, contentMode: .fit)

            Text("insert name here")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showSheet) {
            BiomeExpandedView(biome: Biome(entities: biomeOneExpanded))
                .navigationTransition(.zoom(sourceID: "hi", in: animation))
                .presentationBackground(.black)
        }
        .onTapGesture { showSheet = true }
    }
}
