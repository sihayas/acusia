//
//  SearchScreen.swift
//  acusia
//
//  Created by decoherence on 8/11/24.
//

import MusicKit
import SwiftUI

struct SearchSheet: View {
    @State private var keyboardOffset: CGFloat = 0
    @State private var searchText = "billie"

    var body: some View {
        VStack {
            SearchList(searchText: $searchText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.thinMaterial)
        .presentationCornerRadius(32)
        // Search Bar, Apple Music and Acusia buttons
        .overlay(
            VStack {
                Spacer()

                HStack {
                    Button {} label: {
                        Text("Apple Music")
                            .font(.system(size: 13, weight: .medium))
                            .frame(height: 42)
                            .padding(.horizontal, 12)
                            .background(
                                ZStack {
                                    Color.clear.background(.thinMaterial)
                                        .clipShape(Capsule())
                                    Color.white.opacity(0.1)
                                        .clipShape(Capsule())
                                }
                            )
                            .foregroundColor(.white)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                    }

                    Button {} label: {
                        Text("Acusia")
                            .font(.system(size: 13, weight: .medium))
                            .frame(height: 42)
                            .padding(.horizontal, 12)
                            .background(
                                ZStack {
                                    Color.clear.background(.thinMaterial)
                                        .clipShape(Capsule())
                                    Color.white.opacity(0.1)
                                        .clipShape(Capsule())
                                }
                            )
                            .foregroundColor(.white)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                    }
                }

                SearchBar(searchText: $searchText)
                    .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 24)
                    .offset(y: -keyboardOffset)
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .bottom)
        )
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.spring()) {
                keyboardOffset = 32
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                keyboardOffset = 0
            }
        }
    }
}

// Important: Match Geometry is heavily dependent on where it is on the view hierearchy. For an AsyncImage for example it has be on the outer most. For a shape it has to be above the frame.
struct SearchList: View {
    @StateObject private var musicKitManager = MusicKitManager.shared
    @EnvironmentObject private var safeAreaInsetsManager: SafeAreaInsetsManager

    @Binding var searchText: String
    @Namespace private var animationNamespace

    @State private var selectedResult: SearchResult?
    @State private var searchResults: [SearchResult] = []

    // Shift geometry sizing helpers
    @State private var artworkSize: CGFloat = 56

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                // Search Results
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(searchResults.enumerated()), id: \.element.id) { _, result in
                        if selectedResult?.id != result.id {
                            if let artwork = result.artwork {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(artwork.backgroundColor.map { Color($0) } ?? .clear))
                                    .matchedGeometryEffect(id: result.id, in: animationNamespace)
                                    .transition(.offset())
                                    .frame(width: 186, height: 116)
                                    .overlay(
                                        VStack(alignment: .leading) {
                                            AsyncImage(url: artwork.url(width: 600, height: 600)) { image in
                                                image
                                                    .resizable()
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.gray.opacity(0.25))
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .matchedGeometryEffect(id: "\(result.id)-artwork", in: animationNamespace)
                                            .transition(.offset())
                                            .frame(width: 56, height: 56)

                                            VStack(alignment: .leading) {
                                                Text(result.artistName)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                    .foregroundColor(.white.opacity(0.6))
                                                Text(result.title)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                    .foregroundColor(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(12)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            selectedResult = result
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(.top, safeAreaInsetsManager.insets.top)
                .padding(.horizontal, 24)

                // Selected Result
                if let result = selectedResult, let artwork = result.artwork {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(artwork.backgroundColor.map { Color($0) } ?? .clear))
                        .matchedGeometryEffect(id: result.id, in: animationNamespace)
                        .transition(.offset())
                        .frame(width: 300, height: 300)
                        .overlay(
                            AsyncImage(url: artwork.url(width: 600, height: 600)) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.gray.opacity(0.25))
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .matchedGeometryEffect(id: "\(result.id)-artwork", in: animationNamespace)
                            .transition(.offset())
                            .frame(width: 284, height: 284)
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedResult = nil
                            }
                        }
                }
            }
        }
        .overlay(
            HStack(alignment: .bottom) {
                Text(searchText.isEmpty ? "Index" : "Indexing \"\(searchText)\"")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .padding(24)

                Spacer()
            },
            alignment: .top
        )
        .onAppear {
            Task {
                await performSearch(query: searchText)
            }
        }
        .onChange(of: searchText) { _, query in
            Task {
                await performSearch(query: query)
            }
        }
    }

    private func performSearch(query: String) async {
        searchResults = await musicKitManager.loadCatalogSearchTopResults(searchTerm: query)
    }
}

// struct SearchResultCell: View {
//    let result: SearchResult
//    var animationNamespace: Namespace.ID
//
//    // 192x116
//    var body: some View {
//        if let artwork = result.artwork {
//            RoundedRectangle(cornerRadius: 18, style: .continuous)
//                .fill(Color(artwork.backgroundColor.map { Color($0).opacity(0.25) } ?? .clear))
//                .frame(width: 192, height: 116)
//                .overlay(
//                    VStack(alignment: .leading) {
//                        ArtworkImage(artwork, width: 56, height: 56)
//                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//
//                        VStack(alignment: .leading) {
//                            Text(result.artistName)
//                                .font(.system(size: 13, weight: .regular, design: .rounded))
//                                .lineLimit(1)
//                                .truncationMode(.tail)
//                                .foregroundColor(.white.opacity(0.6))
//                            Text(result.title)
//                                .font(.system(size: 13, weight: .regular, design: .rounded))
//                                .lineLimit(1)
//                                .truncationMode(.tail)
//                                .foregroundColor(.white)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                    .padding(12)
//                )
//                .matchedGeometryEffect(id: result.id, in: animationNamespace)
//                .transition(.scale(scale: 1))
//        }
//    }
// }

// if let result = selectedResult, let artwork = result.artwork {
//    VStack(alignment: .leading) {
//        ArtworkImage(artwork, width: 56, height: 56)
//            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//
//        VStack(alignment: .leading) {
//            Text(result.artistName)
//                .font(.system(size: 13, weight: .regular, design: .rounded))
//                .lineLimit(1)
//                .truncationMode(.tail)
//                .foregroundColor(.white.opacity(0.6))
//            Text(result.title)
//                .font(.system(size: 13, weight: .regular, design: .rounded))
//                .lineLimit(1)
//                .truncationMode(.tail)
//                .foregroundColor(.white)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//    .padding(12)
//    .background(Color(artwork.backgroundColor.map { Color($0).opacity(0.25) } ?? .clear), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
//    .matchedGeometryEffect(id: result.id, in: animationNamespace)
//    .transition(.scale(scale: 1))
//    .onTapGesture {
//        withAnimation(.spring()) {
//            selectedResult = nil
//        }
//    }
// }
