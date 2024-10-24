//
//  SearchScreen.swift
//  acusia
//
//  Created by decoherence on 8/11/24.
//

import Kingfisher
import MusicKit
import SwiftUI
import Transmission

struct IndexSheet: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var musicKitManager: MusicKit

    @State private var keyboardOffset: CGFloat = 0
    @State private var selectedResult: SearchResult?

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(musicKitManager.searchResults.indices, id: \.self) { index in
                    ResultCell(
                        searchResult: $musicKitManager.searchResults[index],
                        selectedResult: $selectedResult
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, safeAreaInsets.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            HStack {
                Text("Index")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(height: safeAreaInsets.top)
        }
    }
}

struct ResultCell: View {
    @EnvironmentObject private var windowState: WindowState
    @Binding var searchResult: SearchResult
    @Binding var selectedResult: SearchResult?

    // Custom Sheet Transition
    @State private var isImageVisible = false
    @State private var progress: CGFloat = 0

    var body: some View {
        HStack(spacing: 12) {
            if let artwork = searchResult.artwork {
                KFImage(artwork.url(width: 1000, height: 1000))
                    .placeholder {
                        Image("placeholderImage")
                            .resizable()
                    }
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: 48, height: 48))
                            |> RoundCornerImageProcessor(cornerRadius: 12)
                    )
                    .serialize(by: FormatIndicatedCacheSerializer.png)
                    .cacheOriginalImage()
                    .scaleFactor(UIScreen.main.scale)
                    .resizable()
                    .onSuccess { result in
                        print("Task done for: \(result.source.url?.absoluteString ?? "")")
                    }
                    .onFailure { error in
                        print("Job failed: \(error.localizedDescription)")
                    }
                    .frame(width: 56, height: 56)
                    .opacity(progress > 0 ? 0 : 1)
            }

            VStack(alignment: .leading) {
                Text(searchResult.artistName)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .lineLimit(1)
                    .foregroundColor(.white.opacity(0.6))

                Text(searchResult.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onTapGesture {
            withAnimation {
                windowState.symmetryState = .reply
                windowState.selectedResult = searchResult
            }
        }
    }
}

struct ImageViewFromCache: View {
    let url: URL?

    var body: some View {
        KFImage(url)
            .setProcessor(RoundCornerImageProcessor(cornerRadius: 32))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 204, height: 204)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
