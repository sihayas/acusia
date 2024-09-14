//
//  SearchScreen.swift
//  acusia
//
//  Created by decoherence on 8/11/24.
//

import MusicKit
import SwiftUI
import Wave

#Preview {
    IndexSheet()
}

struct IndexSheet: View {
    // Global state
    @StateObject private var musicKitManager = MusicKitManager.shared

    @State private var keyboardOffset: CGFloat = 0
    @State private var searchText = "clairo"
    @State private var entryText = ""
    @State private var selectedResult: SearchResult?
    @State private var searchResults: [SearchResult] = []

    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            ResultsView(animationNamespace: animationNamespace, selectedResult: $selectedResult, searchResults: $searchResults)
                .overlay(
                    // Search Bar
                    VStack {
                        Spacer()

                        SearchBar(searchText: $searchText, entryText: $entryText, selectedResult: $selectedResult, animationNamespace: animationNamespace)
                            .padding(.horizontal, 24)
                            .offset(y: -keyboardOffset)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground(.thinMaterial)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .presentationCornerRadius(32)
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

//VStack {
//    if selectedResult != nil {
//        SubmissionView(animationNamespace: animationNamespace, selectedResult: $selectedResult)
//    }
//}
//.id(1)
//.frame(minWidth: UIScreen.main.bounds.width)
