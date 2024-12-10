//
//  BiomePreviewView.swift
//  acusia
//
//  Created by decoherence on 12/6/24.
//
import SwiftUI

struct BiomePreviewView: View {
    @EnvironmentObject private var windowState: UIState

    let biome: Biome

    @Namespace var animation
    @State private var showSheet: Bool = false
    @State private var totalHeight: CGFloat = 0
    @State private var firstMessageSize: CGSize = .zero

    private let shadowColor: Color = .init(red: 197/255, green: 197/255, blue: 197/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0 ..< 2, id: \.self) { index in
                let previousEntity = index > 0 ? biome.entities[index - 1] : nil

                EntityView(
                    rootEntity: biome.entities[0],
                    previousEntity: previousEntity,
                    entity: biome.entities[index]
                )
                .frame(maxHeight: .infinity)
                .background(GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            if index == 0 {
                                firstMessageSize = proxy.size
                            }
                        }
                })
            }

            /// Typing indicator
            HStack(alignment: .bottom, spacing: 8) {
                CollageLayout {
                    ForEach(userDevs.prefix(3), id: \.id) { user in
                        Circle()
                            .background(
                                AsyncImage(url: URL(string: user.imageUrl)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                            )
                            .foregroundStyle(.clear)
                            .clipShape(Circle())
                    }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("coolgirl, saraton1nn, joji and 2 more...")
                        .font(.system(size: 11))
                        .padding(.leading, 10)

                    Image(systemName: "ellipsis")
                        .fontWeight(.bold)
                        .font(.system(size: 21))
                        .foregroundStyle(Color(.systemGray2))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6), in: BubbleWithTailShape(scale: 1))
                        .padding(.bottom, 4)
                }
            }
            .padding(.top, 12)
        }
        .padding(24)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        totalHeight = proxy.size.height
                        print(totalHeight)
                    }
            }
        )
        .frame(maxWidth: .infinity)
        .frame(minHeight: totalHeight)
        .frame(
            height: totalHeight > 0
                ? totalHeight - (firstMessageSize.height * 0.92)
                : nil,
            alignment: .bottom
        )
        .overlay(alignment: .top) {
            VariableBlurView(radius: 4, mask: Image(.gradient))
                .ignoresSafeArea()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: firstMessageSize.height * 0.26
                )
                .scaleEffect(x: 1, y: -1)
        }
        .background(
            .black
                .shadow(
                    .inner(
                        color: .white.opacity(0.15),
                        radius: 24,
                        x: 0,
                        y: 0
                    )
                ),
            in: RoundedRectangle(cornerRadius: 40, style: .continuous)
        )
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .foregroundStyle(.secondary)
        .shadow(radius: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .stroke(.ultraThinMaterial, lineWidth: 0.05)
        )
        .matchedTransitionSource(id: "hi", in: animation)
        .sheet(isPresented: $showSheet) {
            BiomeExpandedView(biome: Biome(entities: biomeOneExpanded))
                .navigationTransition(.zoom(sourceID: "hi", in: animation))
                .presentationBackground(.black)
        }
        .onTapGesture { showSheet = true }
    }
}

struct BiomePreviewSphereView: View {
    @EnvironmentObject private var windowState: UIState

    let biome: Biome

    @Namespace var animation
    @State private var showSheet: Bool = false

    var body: some View {
        let photos = biome.entities[1].getPhotoAttachments()

        VStack {
            ZStack {
                CollageLayout {
                    ForEach(userDevs.shuffled().prefix(4), id: \.id) { _, user in
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

                Circle()
                    .fill(.ultraThinMaterial)

                CollageLayout {
                    ForEach(userDevs.shuffled().prefix(4), id: \.id) { index, user in
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
                                                            width: proxy.size.width * 3,
                                                            height: proxy.size.width * 3
                                                        )
                                                        .clipped()
                                                } placeholder: {
                                                    Rectangle()
                                                        .foregroundColor(.gray.opacity(0.3))
                                                }
                                            } else {
                                                Text(biome.entities[0].text)
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 12)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(3)
                                            }
                                        }
                                    }
                                    .background(.thinMaterial, in: PreviewBubbleWithTailShape(scale: 1.0))
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
            }
            .aspectRatio(1, contentMode: .fit)

            Text("god's weakest soldiers")
                .font(.footnote)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
