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
            UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 55, bottomTrailingRadius: 55, topTrailingRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
                .foregroundStyle(.clear)
                .background(
                    BlurView(style: .dark, backgroundColor: .black, blurMutingFactor: 0.75)
                        .edgesIgnoringSafeArea(.all)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(1)
                .ignoresSafeArea()
            
            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false) { 
                    HStack(spacing: 0) {
                        ResultsView(animationNamespace: animationNamespace, selectedResult: $selectedResult, searchResults: $searchResults)
                            .frame(width: UIScreen.main.bounds.width)
                            .id(0)

                        VStack {
                            if selectedResult != nil {
                                SubmissionView(animationNamespace: animationNamespace, selectedResult: $selectedResult)
                            }
                        }
                        .id(1)
                        .frame(minWidth: UIScreen.main.bounds.width)
                    }
                }
                .scrollClipDisabled()
                .scrollTargetBehavior(.paging)
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
                .overlay(
                    // Search Bar
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
