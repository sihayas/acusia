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
    @StateObject private var viewModel = SearchViewModel()
    @State private var activeResult: String?
    @State private var visibleResults: [String] = []
    @State var rotation: Double = 45

    var body: some View {
        let cardHeight: CGFloat = 64
        
        GeometryReader {
            let size = $0.size
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, result in
                        SearchResultCell(
                            result: result,
                            index: index,
                            totalCount: viewModel.searchResults.count,
                            activeResult: activeResult,
                            size: size,
                            cardHeight: cardHeight
                        )
                        .padding(.bottom, 12)
                    }
                }
                .scrollTargetLayout()

            }
            .padding(.horizontal, 24)
            .scrollClipDisabled()
//            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $activeResult)
            .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.5) { visibleIds in
                 // Filter and map only the IDs above the threshold
                 visibleResults = visibleIds.compactMap { id in
                     viewModel.searchResults.first { $0.id == id }?.title
                 }
                 print("Visible results (names): \(visibleResults)")
             }
            .onChange(of: searchText) { _, newValue in
                Task {
                    await viewModel.performSearch(query: newValue)
                    activeResult = viewModel.searchResults.first?.id
                }
            }
            .onChange(of: activeResult) { _, newValue in
//                print("Active result: \(newValue ?? "nil")")
            }
        }
    }
}

// MARK: Search Result Cell
struct SearchResultCell: View {
    @State private var isVisible = false
    @State private var scale: CGFloat = 1

    let result: SearchResultItem
    let index: Int
    let totalCount: Int
    let activeResult: String?
    let size: CGSize
    let cardHeight: CGFloat

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
