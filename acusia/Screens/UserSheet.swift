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

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 48, style: .continuous)
                            .strokeBorder(.ultraThinMaterial, lineWidth: 2)
                    )
                    .padding(16)
                
                BiomePreviewView(biome: Biome(entities: biomePreviewOne))
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 48, style: .continuous)
                            .strokeBorder(.ultraThinMaterial, lineWidth: 2)
                    )
                    .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaPadding([.bottom, .top])
    }
}
