//
//  ResultsView.swift
//  acusia
//
//  Created by decoherence on 9/13/24.
//
import Kingfisher
import SwiftUI
import Transmission

struct ResultsView: View {
    @Binding var searchResults: [SearchResult]
    @Binding var selectedResult: SearchResult?

    var body: some View {
        VStack(spacing: 16) {
            ForEach(searchResults.indices, id: \.self) { index in
                ResultCell(
                    searchResult: $searchResults[index],
                    selectedResult: $selectedResult
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 64)
        .padding(.bottom, 64)
    }
}

struct ResultCell: View {
    @Binding var searchResult: SearchResult
    @Binding var selectedResult: SearchResult?

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
                        DownsamplingImageProcessor(size: CGSize(width: 40, height: 40))
                            |> RoundCornerImageProcessor(cornerRadius: 12)
                    )
                    .cacheOriginalImage()
                    .scaleFactor(UIScreen.main.scale)
                    .resizable() // Make the image resizable to fit the view
                    .onSuccess { result in
                        print("Task done for: \(result.source.url?.absoluteString ?? "")")
                    }
                    .onFailure { error in
                        print("Job failed: \(error.localizedDescription)")
                    }
                    .frame(width: 40, height: 40) // Adjust the frame as needed
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .opacity(progress > 0 ? 0 : 1)
                    .presentation(
                        transition: .custom(CustomTransition {
                            isImageVisible = true
                        }),
                        isPresented: $showSheet
                    ) {
                        TransitionReader { proxy in
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .background(.thinMaterial)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                    .ignoresSafeArea()

                                VStack {
                                    ImprintView(result: $searchResult)
                                }

                                ImageViewFromCache(url: artwork.url(width: 1000, height: 1000))
                            }
                            .edgesIgnoringSafeArea(.vertical)
                            .onChange(of: proxy.progress) {_, newValue in
                                progress = newValue
                            }
                        }
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
