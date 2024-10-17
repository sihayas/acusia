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
    // Global state
    @EnvironmentObject var windowState: WindowState
    @StateObject private var musicKitManager = MusicKit.shared

    @State private var keyboardOffset: CGFloat = 0
    @State private var selectedResult: SearchResult?

    var body: some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 45, bottomLeadingRadius: 55, bottomTrailingRadius: 55, topTrailingRadius: 45, style: .continuous)
                .foregroundStyle(.clear)
                .background(
                    TintedBlurView(style: .systemChromeMaterialDark, backgroundColor: .black, blurMutingFactor: 0.5)
                        .edgesIgnoringSafeArea(.all)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(musicKitManager.searchResults.indices, id: \.self) { index in
                        ResultCell(
                            searchResult: $musicKitManager.searchResults[index],
                            selectedResult: $selectedResult
                        ) {
                            /// Having the environment object directly in the cell breaks Wave animator.
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)
                .padding(.bottom, 64)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground(.clear)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(40)
        .overlay(
            // Search Bar
            VStack {
                HStack {
                    Text("Index")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.leading, 24)
                .padding(.top, 24)

                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .bottom)
        )
    }
}

struct ResultCell: View {
    @Binding var searchResult: SearchResult
    @Binding var selectedResult: SearchResult?
    
    var onShowSheetChange: () -> Void

    // Custom Sheet Transition
    @State private var showSheet = false
    @State private var isImageVisible = false
    @State private var progress: CGFloat = 0

    var body: some View {
        HStack(spacing: 12) {
            if let artwork = searchResult.artwork {
                let backgroundColor = artwork.backgroundColor.map { Color($0) } ?? Color.clear
                let isSong = searchResult.type == "Song"

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
                    .resizable() // Make the image resizable to fit the view
                    .onSuccess { result in
                        print("Task done for: \(result.source.url?.absoluteString ?? "")")
                    }
                    .onFailure { error in
                        print("Job failed: \(error.localizedDescription)")
                    }
                    .forceRefresh()
                    .frame(width: 48, height: 48) // Adjust the frame as needed
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .opacity(progress > 0 ? 0 : 1)
                    .presentation(
                        transition: .custom(CustomTransition {
                            isImageVisible = true
                        }),
                        isPresented: $showSheet
                    ) {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .background(
                                    TintedBlurView(style: .systemChromeMaterialDark, backgroundColor: .black, blurMutingFactor: 0.5)
                                        .edgesIgnoringSafeArea(.all)
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .ignoresSafeArea()
                            

                            VStack {
                                ImprintView(result: $searchResult)
                            }

                            ImageViewFromCache(url: artwork.url(width: 1000, height: 1000))
                                .opacity(0)
                        }
                        .edgesIgnoringSafeArea(.vertical)
                    }
            }

            VStack(alignment: .leading) {
                Text(searchResult.artistName)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .lineLimit(1)
                    .foregroundColor(.white.opacity(0.6))

                Text(searchResult.title)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .lineLimit(1)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            withAnimation {
                showSheet.toggle()
            }
        }
        .onChange(of: showSheet) { _, _ in
              onShowSheetChange()
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

//                .overlay(
//                    RoundedRectangle(cornerRadius: 16, style: .continuous)
//                        .strokeBorder(
//                            style: StrokeStyle(
//                                lineWidth: 1,
//                                lineCap: .round,
//                                dash: [5]
//                            )
//                        )
//                        .foregroundColor(
//                            isSong ? Color.white.opacity(0) : backgroundColor
//                        )
//                )
