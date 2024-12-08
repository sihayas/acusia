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
                // .scaleEffect(index == 0 ? 0.96 : 1.0)
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
                    maxHeight: firstMessageSize.height * 0.28
                )
                .scaleEffect(x: 1, y: -1)
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .foregroundStyle(.secondary)
        .matchedTransitionSource(id: "hi", in: animation)
        .sheet(isPresented: $showSheet) {
            BiomeExpandedView(biome: Biome(entities: biomeOneExpanded))
                .navigationTransition(.zoom(sourceID: "hi", in: animation))
                .presentationBackground(.black)
        }
        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 8)
        .onTapGesture { showSheet = true }
    }
}
