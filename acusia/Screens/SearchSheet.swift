//
//  SearchScreen.swift
//  acusia
//
//  Created by decoherence on 8/11/24.
//

import SwiftUI
 
struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            ZStack {
                TextField("Index", text: $searchText, axis: .horizontal)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .transition(.opacity)
                    .frame(minHeight: 48)
            }
        }
        .padding(.horizontal, 16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
        .frame(height: 48)
    }
}

struct SearchSheet: View {
    @Binding var path: NavigationPath
    @Binding var searchText: String
    @StateObject private var musicKitManager = MusicKitManager.shared
    @State private var activeResult: String?
    @State private var searchResults: [SearchResultItem] = []
    @State var rotation: Double = 45

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(searchResults.enumerated()), id: \.element.id) { index, result in
                        SearchResultCell(
                            result: result,
                            index: index,
                            totalCount: searchResults.count,
                            activeResult: activeResult,
                            size: geometry.size
                        )
                        .padding(.bottom, 12)
                    }
                }
            }
            .padding(.horizontal, 24)
            .onChange(of: searchText) { _, newValue in
                Task {
                    await performSearch(query: newValue)
                    activeResult = searchResults.first?.id
                }
            }
        }
    }

    private func performSearch(query: String) async {
        await musicKitManager.loadCatalogSearchTopResults(searchTerm: query)
        // Here you should map the response to `SearchResultItem` to update `searchResults`
        // This assumes you will have a mapping logic for the items returned by MusicKit
    }
}

// MARK: Search Result Cell
struct SearchResultCell: View {
    let result: SearchResultItem
    let index: Int
    let totalCount: Int
    let activeResult: String?
    let size: CGSize
    let cardHeight: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThickMaterial)
                .frame(height: cardHeight)
                .overlay(
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(result.title)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Text(result.subtitle)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        AsyncImage(url: result.imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } placeholder: {
                            Color.clear
                        }
                    }
                    .padding(12)
                    .frame(height: cardHeight, alignment: .leading)
                )
                .frame(height: cardHeight)
        }
    }
}
