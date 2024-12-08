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
            HStack() {
                AvatarView(size: 48, imageURL: "https://pbs.twimg.com/profile_images/1863668966167601152/OQ34VUQ-_400x400.png")
                
                VStack(alignment: .leading) {
                    Text("Alia")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("@alia")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                }
                
                Spacer()
            }
            .safeAreaPadding([.bottom, .top])
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 12) {
                BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
                    .padding(.horizontal, 24)
                
                BiomePreviewView(biome: Biome(entities: biomePreviewOne))
                    .padding(.horizontal, 24)
            }
        }
        .scrollClipDisabled()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaPadding([.bottom, .top])
    }
}
