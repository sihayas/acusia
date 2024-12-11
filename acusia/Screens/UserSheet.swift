//
//  UserSheet.swift
//  acusia
//
//  Created by decoherence on 12/6/24.
//
import SwiftUI

struct UserSheet: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var uiState: UIState

    private let columns = [
        GridItem(.flexible(), spacing: 32),
        GridItem(.flexible(), spacing: 32),
        GridItem(.flexible(), spacing: 32)
    ]

    private let biomes = [
        Biome(entities: biomePreviewOne),
        Biome(entities: biomePreviewTwo),
        Biome(entities: biomePreviewOne),
        Biome(entities: biomePreviewTwo)
        
    ]

    var body: some View {
        ScrollView {
            HStack(alignment: .bottom) {
                Spacer()

                Text("Alia")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                AvatarView(
                    size: 48,
                    imageURL: "https://pbs.twimg.com/profile_images/1863668966167601152/OQ34VUQ-_400x400.png"
                )
            }
            .frame(maxWidth: .infinity)
            .safeAreaPadding(.all)

            LazyVGrid(columns: columns, spacing: safeAreaInsets.top * 2) {
                ForEach(0 ..< biomes.count, id: \.self) { index in
                    BiomePreviewSphereView(biome: biomes[index])
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, safeAreaInsets.top * 1.5)
        }
        .scrollClipDisabled()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground(.black)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(50)
    }
}
