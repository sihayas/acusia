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
    @State private var searchText = "clairo"
    @State private var selectedResult: SearchResult?

    @Namespace private var animationNamespace

    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    SearchList(searchText: $searchText, animationNamespace: animationNamespace, selectedResult: $selectedResult)
                        .frame(width: UIScreen.main.bounds.width)
                        .id(0)

                    VStack {
                        if let result = selectedResult {
                            DetailedSearchResult(result: result, animationNamespace: animationNamespace, selectedResult: $selectedResult)
                        }
                    }
                    .id(1)
                    .frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)
                }
            }
            .scrollClipDisabled()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.black)
            .presentationCornerRadius(32)
            .onChange(of: selectedResult) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring()) {
                        if selectedResult != nil {
                            value.scrollTo(1)
                        } else {
                            value.scrollTo(0)
                        }
                    }
                }
            }
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
}

// Important: Match Geometry is heavily dependent on where it is on the view hierearchy. For an AsyncImage for example it has be on the outer most. For a shape it has to be above the frame. ScrollClipDisabled was necessary to prevent the cell from being clipped as it went from one part of the parent HStack scrollview to the other. Also, I had to use a custom non-lazy v grid because as soon as the lazy v grid moved away from the view, it un-rendered the cells so match geometry broke.
struct SearchList: View {
    @StateObject private var musicKitManager = MusicKitManager.shared
    @EnvironmentObject private var safeAreaInsetsManager: SafeAreaInsetsManager

    @Binding var searchText: String
    var animationNamespace: Namespace.ID

    @Binding var selectedResult: SearchResult?
    @State private var searchResults: [SearchResult] = []

    // Shift geometry sizing helpers
    @State private var artworkSize: CGFloat = 56
    @State private var maxRowHeight: CGFloat = 0.0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VGrid(VGridConfiguration(
                numberOfColumns: 2,
                itemsCount: searchResults.count,
                alignment: .leading,
                hSpacing: 12,
                vSpacing: 12)
            ) { index in
                // Ensure each case returns a valid View
                Group {
                    if let artwork = searchResults[index].artwork {
                        let color = artwork.backgroundColor.map { Color($0).opacity(0.25) } ?? .clear
                        ZStack {
                            if selectedResult?.id != searchResults[index].id {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(color)
                                    .fill(.black)
                                    .matchedGeometryEffect(id: "result-\(searchResults[index].id)", in: animationNamespace)
                                    .frame(width: 186, height: 124)
                                    .overlay(
                                        VStack(alignment: .leading) {
                                            AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                                                image
                                                    .resizable()
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.gray.opacity(0.25))
                                            }
                                            .matchedGeometryEffect(id: "\(searchResults[index].id)-artwork", in: animationNamespace)
                                            .frame(width: 56, height: 56)
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .leading) {
                                                Text(searchResults[index].artistName)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                    .foregroundColor(.white.opacity(0.6))
                                                Text(searchResults[index].title)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                    .foregroundColor(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(12)
                                    )
                                    .readSize { size in
                                        maxRowHeight = max(size.height, maxRowHeight)
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(.secondary)
                                    .fill(.black)
                                    .frame(width: 186, height: 124)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedResult = searchResults[index]
                            }
                        }
                        .transition(.scale(scale: 1))
                    } else {
                        EmptyView()
                    }
                }
            }
            .padding(.top, safeAreaInsetsManager.insets.top)
            .padding(.horizontal, 24)
        }
        .scrollClipDisabled()
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

struct DetailedSearchResult: View {
    let result: SearchResult
    var animationNamespace: Namespace.ID
    @Binding var selectedResult: SearchResult?

    var body: some View {
        if let artwork = result.artwork {
            let color = artwork.backgroundColor.map { Color($0).opacity(0.25) } ?? .clear
            
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(color)
                    .fill(.black)
                    .matchedGeometryEffect(id: "result-\(result.id)", in: animationNamespace)
                    .frame(width: 300, height: 300)
                    .overlay(
                        AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                            image
                                .resizable()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.gray.opacity(0.25))
                        }
                        .matchedGeometryEffect(id: "\(result.id)-artwork", in: animationNamespace)
                        .frame(width: 284, height: 284)
                    )
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedResult = nil
                }
            }
            .transition(.scale(scale: 1))
        }
    }
}
