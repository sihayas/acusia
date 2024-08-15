//
//  SearchScreen.swift
//  acusia
//
//  Created by decoherence on 8/11/24.
//

import SwiftUI
import BigUIPaging

struct CardDeckExample: View {
    
    @State private var selection: Int = 1
    private let totalPages = 10
    
    var body: some View {
        VStack {
            PageView(selection: $selection) {
                ForEach(1...totalPages, id: \.self) { value in
                    ExamplePage(value: value)
                        // Resize to be more card-like.
                        .aspectRatio(0.7, contentMode: .fit)
                }
            }
            // Set the card style
            .pageViewStyle(.cardDeck)
            // Card styling options
            .pageViewCardCornerRadius(45.0)
            .pageViewCardShadow(.visible)
            // A tap gesture works great here
            .onTapGesture {
                print("Tapped card \(selection)")
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity)
        .border(Color.red)
    }
    
    // Here's where you'd map your selection to a page index.
    // In this example it's just the selection minus one.
    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}

struct ExamplePage: View {
    
    let value: Int
    
    var body: some View {
//        let _ = Self._printChanges()
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(value.color)
                    .ignoresSafeArea()
                Image(systemName: "\(value).circle.fill")
                    .font(.system(size: geometry.size.height / 4))
                    .foregroundStyle(.white)
            }
        }
    }
}

extension Int {
    
    var color: Color {
        switch self % 10 {
        case 0: return .pink
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .mint
        case 6: return .teal
        case 7: return .blue
        case 8: return .indigo
        case 9: return .purple
        default: return .gray
        }
    }
}
 
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


struct SearchResultsList: View {
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
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Text(result.title)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text(result.subtitle)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        AsyncImage(url: result.imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } placeholder: {
                            Color.clear
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .frame(height: cardHeight, alignment: .center)
                )
                .frame(height: cardHeight)
        }
    }
}
