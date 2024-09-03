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
    @State private var entryText = ""
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
                    .frame(minWidth: UIScreen.main.bounds.width)
                }
            }
            .scrollClipDisabled()
            .scrollTargetBehavior(.paging)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.black)
            .presentationCornerRadius(32)
            .onChange(of: selectedResult) { _, _ in
                // Scroll to respective page when user (un)selects a result.
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

                    SearchBar(searchText: $searchText, entryText: $entryText, selectedResult: $selectedResult, animationNamespace: animationNamespace)
                        .padding(.horizontal, 24)
                        .offset(y: -keyboardOffset)
                }
                .frame(width: UIScreen.main.bounds.width, alignment: .bottom)
            )
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation(.spring()) {
                    keyboardOffset = 8
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

    @State private var maxRowHeight: CGFloat = 0.0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VGrid(VGridConfiguration(
                numberOfColumns: 2,
                itemsCount: searchResults.count,
                alignment: .leading,
                hSpacing: 12,
                vSpacing: 12
            )
            ) { index in
                // Ensure each case returns a valid View
                Group {
                    if let artwork = searchResults[index].artwork {
                        let backgroundColor = artwork.backgroundColor.map { Color($0) } ?? Color.clear

                        ZStack {
                            if selectedResult?.id != searchResults[index].id {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(backgroundColor.mix(with: .black, by: 0.5))
                                    .matchedGeometryEffect(id: "result-\(searchResults[index].id)", in: animationNamespace)
                                    .frame(width: 186, height: 112)
                                    .overlay(
                                        VStack(alignment: .leading) {
                                            AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                                                image
                                                    .resizable()
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.gray.opacity(0.25))
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .matchedGeometryEffect(id: "\(searchResults[index].id)-artwork", in: animationNamespace)
                                            .aspectRatio(contentMode: .fit)

                                            VStack(alignment: .leading) {
                                                Text(searchResults[index].artistName)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .foregroundColor(.white.opacity(0.6))
                                                    .matchedGeometryEffect(id: "artistName-\(searchResults[index].id)", in: animationNamespace)

                                                Text(searchResults[index].title)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .foregroundColor(.white)
                                                    .matchedGeometryEffect(id: "title-\(searchResults[index].id)", in: animationNamespace)
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
                            .frame(width: 186, height: 124)
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
    @EnvironmentObject private var safeAreaInsetsManager: SafeAreaInsetsManager

    let result: SearchResult
    var animationNamespace: Namespace.ID
    @Binding var selectedResult: SearchResult?

    var body: some View {
        if let artwork = result.artwork {
            let backgroundColor = artwork.backgroundColor.map { Color($0) } ?? Color.clear

            VStack(spacing: 0) {
                HStack {
                    // Writing symbol
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    VStack {
                        Text(result.artistName)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .matchedGeometryEffect(id: "artistName-\(result.id)", in: animationNamespace)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(result.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .matchedGeometryEffect(id: "title-\(result.id)", in: animationNamespace)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer()
                }
                .padding(24)

                ZStack {
                    VStack {
                        AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                            image
                                .resizable()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.gray.opacity(0.25))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .matchedGeometryEffect(id: "\(result.id)-artwork", in: animationNamespace)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 196, height: 196)
                    }
                    
                    VStack {
                        Spacer()
                        
                        MorphView()
                    }
                }
                .frame(width: UIScreen.current?.bounds.size.width, height: UIScreen.current?.bounds.size.width)

                Spacer()
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
