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
                        if entry.rating == 2 {
                            Wisp(
                                entry: entry,
                                namespace: ns,
                                scrolledEntryID: scrolledEntryID,
                                onDelete: deleteEntry
                            )
                        } else {
                            Artifact(
                                entry: entry,
                                namespace: ns,
                                scrolledEntryID: scrolledEntryID,
                                expandedEntryID: $expandedEntryID,
                                onDelete: deleteEntry
                            )
                        }
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
            
            // Container for expanded text card
            GeometryReader { _ in
                if let expandedID = expandedEntryID,
                   let expandedEntry = viewModel.entries.first(where: { $0.id == expandedID })
                {
                    HStack(spacing: -48) {
                        TextCard(entry: expandedEntry, namespace: ns)
                            .zIndex(1)
                            .padding(.bottom, 16)
                            .rotationEffect(.degrees(-2))
                        SoundCard(entry: expandedEntry, namespace: ns)
                            .rotationEffect(.degrees(2))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(24)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            expandedEntryID = nil
                        }
                    }
                }
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

struct Artifact: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    let scrolledEntryID: APIEntry.ID?
    @Binding var expandedEntryID: APIEntry.ID?
    let onDelete: (String) async -> Void
    
    @State private var isSheetPresented = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.author.username)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .padding(.leading, 64)
                .padding(.bottom, 4)
                
            HStack(alignment: .top, spacing: 12) {
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
                    
                VStack(alignment: .leading, spacing: -32) {
                    // MARK: Sound Card View

                    if expandedEntryID != entry.id {
                        ZStack(alignment: .bottomLeading) {
                            // Ambiance
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [.white, .clear]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 40
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            SoundCard(entry: entry, namespace: namespace)
                                .overlay(
                                    HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                                        .offset(x: 20, y: -20),
                                    alignment: .topTrailing
                                )
                        }
                        .rotationEffect(.degrees(2), anchor: .center)
                    }
                        
                    // MARK: Text Card View

                    HStack {
                        Spacer()
                        if expandedEntryID != entry.id {
                            TextCard(entry: entry, namespace: namespace)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        expandedEntryID = entry.id
                                        isSheetPresented = true
                                    }
                                }
                                .contextMenu {
                                    Menu {
                                        Button {
                                            // Flag functionality
                                        } label: {
                                            Label("Spam", systemImage: "exclamationmark.triangle")
                                        }
                                    } label: {
                                        Label("Flag", systemImage: "flag.fill")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 24)
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

struct Wisp: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    let scrolledEntryID: APIEntry.ID?
    let onDelete: (String) async -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Avatar Image View
            NavigationLink {
                EmptyView()
            } label: {
                AsyncImage(url: URL(string: entry.author.image)) { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
            }
            
            // Wisp
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .leading) {
                    // Ambiance
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: entry.sound.appleData?.artworkBgColor ?? "FFFFFF"), .clear]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.thinMaterial)
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
                                    Text(entry.sound.appleData?.artistName ?? "")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.4))
                                        .lineLimit(1)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(entry.sound.appleData?.name ?? "")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color.white.opacity(0.7))
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TextCard: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(.thinMaterial)
            .frame(width: 216, height: 304)
            .shadow(radius: 8)
            .overlay(
                Text(entry.text)
                    .foregroundColor(Color.white)
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .frame(width: 216, height: 304, alignment: .topLeading)
            )
            .matchedGeometryEffect(id: "textCard_\(entry.id)", in: namespace)
    }
}

struct SoundCard: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(.thinMaterial)
            .frame(width: 216, height: 304)
            .shadow(radius: 8)
            .overlay(
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink {
                        EmptyView()
                            .navigationTransition(.zoom(sourceID: entry.sound.id, in: namespace))
                    } label: {
                        AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .matchedTransitionSource(id: entry.sound.id, in: namespace)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 32,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 32,
                                        style: .continuous
                                    )
                                )
                                .layoutPriority(1)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(entry.sound.appleData?.artistName ?? "")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.secondary)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                        Text(entry.sound.appleData?.name ?? "")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 4)
                        
                        Image("heartbreak")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .frame(width: 216, height: 304, alignment: .topLeading)
            )
            .matchedGeometryEffect(id: "soundCard_\(entry.id)", in: namespace)
    }
}
