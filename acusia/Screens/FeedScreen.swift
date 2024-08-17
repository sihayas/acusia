//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//
import Combine
import SwiftUI

struct FeedScreen: View {
    @StateObject private var musicPlayer = MusicPlayer()
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
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
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
            .onChange(of: viewModel.entries) { _, newEntries in
                if let firstEntry = viewModel.entries.first {
                    scrolledEntryID = firstEntry.id
                }
                Task {
                    await musicPlayer.updateQueue(with: newEntries)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: -8) {
            HStack(alignment: .bottom, spacing: 12) {
                NavigationLink {
                    EmptyView()
                } label: {
                    AsyncImage(url: URL(string: entry.author.image)) { image in
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        EmptyView()
                    }
                    .matchedTransitionSource(id: entry.id, in: namespace)
                }
                    
                VStack(alignment: .leading, spacing: 8) {
                    // Render card if entry is an artifact.
                    if entry.rating != 2 {
                        SoundCard(entry: entry, namespace: namespace)
                            .overlay(
                                HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                                    .offset(x: 20, y: -20),
                                alignment: .topTrailing
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.clear)
                            .frame(width: .infinity, height: 72)
                            .overlay(
                                HStack(spacing: 0) {
                                    AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                                        image
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .padding(12)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                        
                                    VStack(alignment: .leading) {
                                        Text(entry.sound.appleData?.albumName ?? "")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .lineLimit(1)
                                            .multilineTextAlignment(.leading)
                                        Text(entry.sound.appleData?.artistName ?? "")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Color.white.opacity(0.7))
                                            .lineLimit(1)
                                            .multilineTextAlignment(.leading)
                                            
                                        Text(entry.sound.appleData?.name ?? "")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(Color.white)
                                            .lineLimit(1)
                                            .multilineTextAlignment(.leading)
                                        
                                    }
                                        
                                    Spacer()
                                }
                            )
                    }
                    
                    ZStack(alignment: .bottomLeading) {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 12, height: 12)
                            .offset(x: 0, y: 0)
                        
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 6, height: 6)
                            .offset(x: -4, y: 4)
                        
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
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            Text(entry.author.username)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .padding(.leading, 64)
        }
        .padding(.vertical, 36)
        .padding(.horizontal, 24)
        .sheet(isPresented: $isSheetPresented) {
            // Sheet content
            VStack {}
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(32)
                .presentationBackground(.thinMaterial)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
    }
}

struct SoundCard: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: 208, height: 208)
                .overlay(
                    HStack(spacing: 12) {
                        Image("heartbreak")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 4)

                        Text(entry.sound.appleData?.name ?? "")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(16),
                    
                    alignment: .topLeading
                )
                .padding(.bottom, 52)
            
            AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedTransitionSource(id: entry.sound.id, in: namespace)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 32,
                            bottomLeadingRadius: 6,
                            bottomTrailingRadius: 6,
                            topTrailingRadius: 32,
                            style: .continuous
                        )
                    )
                    .frame(width: 216, height: 216)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
            } placeholder: {
                ProgressView()
            }
        }
        .rotationEffect(.degrees(-2))
    }
}
