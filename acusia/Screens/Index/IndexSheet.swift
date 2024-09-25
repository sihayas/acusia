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
    @State private var selectedResult: SearchResult?

    var body: some View {
        ScrollView {
            ResultsView(searchResults: $musicKitManager.searchResults, selectedResult: $selectedResult)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground(.thinMaterial)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(40)
        .overlay(
            // Search Bar
            VStack {
                HStack {
                    Image(systemName: "timelapse")
                        .foregroundColor(.white)

                    Text("Index")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.leading, 24)
                .padding(.top, 24)

                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .bottom)
        )

    }
}
