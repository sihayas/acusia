//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import Combine
import SwiftUI

struct FeedScreen: View {
    @StateObject private var viewModel: FeedViewModel
    @Namespace var ns
    
    @State private var scrolledEntryID: APIEntry.ID? // currently active/scrolled entry
    @State private var expandedEntryID: APIEntry.ID? // currently expanded entry
    @State private var deleteError: Error?
    
    private let userId: String
    private let entryAPI = EntryAPI()
    
    init(userId: String, pageUserId: String? = nil) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: FeedViewModel(userId: userId, pageUserId: pageUserId))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(viewModel.entries) { entry in
                    Entry(
                        entry: entry,
                        namespace: ns,
                        scrolledEntryID: scrolledEntryID,
                        expandedEntryID: $expandedEntryID,
                        onDelete: deleteEntry
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollPosition(id: $scrolledEntryID)
        .scrollClipDisabled(true)
        .onChange(of: viewModel.entries) { _, _ in
            if let firstEntry = viewModel.entries.first {
                scrolledEntryID = firstEntry.id
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchEntries()
            }
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { deleteError != nil },
            set: { if !$0 { deleteError = nil } }
        )) {
            Text(deleteError?.localizedDescription ?? "Unknown error")
        }
    }
    
    func deleteEntry(id: String) async {
        do {
            let response = try await entryAPI.deleteEntry(userId: userId, entryId: id)
            guard response.success else { return print("Failed to delete entry") }
            DispatchQueue.main.async { viewModel.removeEntry(id: id) }
            print("Entry deleted successfully")
        } catch {
            deleteError = error
        }
    }
}

struct Entry: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    let scrolledEntryID: APIEntry.ID?
    @Binding var expandedEntryID: APIEntry.ID?
    let onDelete: (String) async -> Void
    
    @State private var isSheetPresented = false
    @State private var isVisible: Bool = false
    @State private var animateFirstCircle = false
    @State private var animateSecondCircle = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            NavigationLink {
                EmptyView()
            } label: {
                AsyncImage(url: URL(string: entry.author.image)) { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(.gray)
                        .frame(width: 40, height: 40)
                }
                .matchedTransitionSource(id: entry.id, in: namespace)
            }
            
            if entry.rating != 2 {
                GooeyView(isVisible: $isVisible, entry: entry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        ZStack(alignment: .bottomLeading) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                                .offset(x: 12, y: -12)
                                .scaleEffect(animateFirstCircle ? 1 : 0, anchor: .topTrailing)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 4, height: 4)
                                .offset(x: 6, y: -10)
                                .scaleEffect(animateSecondCircle ? 1 : 0, anchor: .topTrailing)
                        },
                        alignment: .bottomLeading
                    )
            } else {
                WispView(entry: entry, namespace: namespace)
            }
        }
        .padding(.horizontal, 24)
        .onScrollVisibilityChange(threshold: 0.7) { visibility in
            isVisible = visibility
        }
        .sheet(isPresented: $isSheetPresented) {
            // Sheet content
            VStack {}
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(32)
                .presentationBackground(.thinMaterial)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                withAnimation(.spring().delay(0.3)) {
                    animateFirstCircle = true
                    animateSecondCircle = true
                }
            }
        }
    }
}

struct WispView: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.clear)
                .frame(width: .infinity, height: 72)
                .overlay(
                    HStack(spacing: 12) {
                        VStack {
                            AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                                image
                                    .resizable()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .shadow(color: .black.opacity(0.7), radius: 16, x: 0, y: 4)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        .padding(4)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        VStack(alignment: .leading) {
                            Text(entry.sound.appleData?.artistName ?? "")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color.white)
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            
                            Text(entry.sound.appleData?.name ?? "")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.white)
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                )
            
            ZStack(alignment: .bottomLeading) {
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: 12, height: 12)
                    .offset(x: 0, y: 0)
                
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: 6, height: 6)
                    .offset(x: -6, y: 4)
                
                Text(entry.text)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding([.bottom, .leading], 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
