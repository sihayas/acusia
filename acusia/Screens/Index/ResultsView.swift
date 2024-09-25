//
//  ResultsView.swift
//  acusia
//
//  Created by decoherence on 9/13/24.
//
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

    var body: some View {
        HStack(spacing: 12) {
            if let artwork = searchResult.artwork {
                let backgroundColor = artwork.backgroundColor.map { Color($0) } ?? Color.clear
                let isSong = searchResult.type == "Song"

                AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                    image.resizable()
                } placeholder: {
                    Rectangle()
                        .frame(width: 40, height: 40)
                }
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .frame(height: 40)
                .presentation(
                    transition: .custom(CustomTransition {
                        isImageVisible = true
                    }),
                    isPresented: $showSheet
                ) {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .background(.thinMaterial)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .ignoresSafeArea()
                        
                        VStack {
                            ImprintView(result: $searchResult)
                        }

                        AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                            image.resizable()
                        } placeholder: {
                            Rectangle()
                        }
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 204, height: 204)
                        .opacity(isImageVisible ? 0 : 0) // 1
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
