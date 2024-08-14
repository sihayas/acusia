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
        .background(Color(UIColor.black))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
        .frame(height: 48)
    }
}


struct SearchResultsList: View {
    @Binding var path: NavigationPath
    @Binding var searchText: String
    @StateObject private var viewModel = SearchViewModel()
    @State private var activeResult: String?
    @State var rotation: Double = 45

    var body: some View {
        let cardHeight: CGFloat = 128
        
        GeometryReader {
            let size = $0.size
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, result in
                        SearchResultCell(
                            result: result,
                            index: index,
                            totalCount: viewModel.searchResults.count,
                            activeResult: activeResult,
                            size: size,
                            cardHeight: cardHeight
                        )
                        .visualEffect { content, geometryProxy in
                            content
                                .rotation3DEffect(.init(degrees: rotation(geometryProxy)),
                                                  axis: (x: 1, y: 0, z: 0),
                                                  anchor: .center,
                                                  perspective: 0.5
                                )
                        }
                        .padding(.bottom, 0)
                    }
                }
                .padding(.vertical, (size.height - cardHeight) / 2.0)
                .scrollTargetLayout()
            }
            .scrollClipDisabled()
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $activeResult)
            .onChange(of: searchText) { _, newValue in
                Task {
                    await viewModel.performSearch(query: newValue)
                    activeResult = viewModel.searchResults.first?.id
                }
            }
            .onChange(of: activeResult) { _, _ in
            // print("Active result: \(newValue ?? "nil")")
            }
        }
    }
    
    func rotation(_ proxy: GeometryProxy) -> Double {
        let scrollViewHeight = proxy.bounds(of: .scrollView(axis: .vertical))?.height ?? 0
        let midY = proxy.frame(in: .scrollView(axis: .vertical)).midY
        let progress = midY / scrollViewHeight
        let cappedProgress = max(min(progress, 1.0), 0.0)
        let cappedRotation = max(min(rotation, 90), 0)
        let degree = (1 - cappedProgress) * (rotation * 2)
        return cappedRotation - degree
    }
}

// MARK: Search Result Cell
struct SearchResultCell: View {
    @State private var isVisible = false
    @State private var isSeen = false

    let result: SearchResultItem
    let index: Int
    let totalCount: Int
    let activeResult: String?
    let size: CGSize
    let cardHeight: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.clear)
            .frame(width: size.width - 48, height: cardHeight)
            .overlay(
                HStack(spacing: 0) {
                    AsyncImage(url: result.imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } placeholder: {
                        Color.clear
                    }
                }
                .frame(width: size.width - 48, height: cardHeight)
            )
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
            .blur(radius: isVisible ? 0 : 4)
            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.05), value: isVisible)
            .onAppear {
                withAnimation(.easeOut(duration: 0.1).delay(Double(index) * 0.05)) {
                    isVisible = true
                }
            }
    }
}
