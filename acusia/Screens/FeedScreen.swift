//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import SwiftUI
import Combine
import BigUIPaging

struct CardDeck: View {
    @Namespace private var namespace
    let entry: APIEntry
    @State private var selection: Int = 1
    
    
    var body: some View {
        VStack {
            // Use ForEach with a collection of identifiable data
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        TextCard(entry: entry, namespace: namespace)
                    } else {
                        SoundCard(entry: entry, namespace: namespace)
                    }
                }
            }
            .pageViewStyle(.cardDeck)
            .pageViewCardCornerRadius(45.0)
            .pageViewCardShadow(.visible)
        }
    }
    
    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}

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
                            CardDeck(entry: entry)
                                .frame(width: 270, height: 386)
                        }
                    }
                }
                .scrollTargetLayout()
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
            GeometryReader { geometry in
                if let expandedID = expandedEntryID,
                   let expandedEntry = viewModel.entries.first(where: { $0.id == expandedID }) {
                    HStack(spacing: -48){
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
        } catch {
            deleteError = error
        }
    }
}


struct TextCard: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(Color(UIColor.systemGray6))
                    .ignoresSafeArea()
                    .overlay(
                        VStack(alignment: .leading) {
                            Text(entry.text)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.white)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 4)
                        }

                    )
            }
        }
    }
}

struct SoundCard: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
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
            NavigationLink {
                EmptyView()
                    .navigationTransition(.zoom(sourceID: entry.sound.id, in: namespace))
            } label: {
                AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 176, height: 176)
                        .matchedTransitionSource(id: entry.sound.id, in: namespace)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: -15)
                } placeholder: {
                    ProgressView()
                }
            }
            
            Spacer()

            Image("heartbreak")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(.black)
                .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 4)

        }
        .frame(width: 216, height: 304, alignment: .trailing)
        .background(Color(UIColor.systemGray6))
    }
}


struct Wisp: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    let scrolledEntryID: APIEntry.ID?
    let onDelete: (String) async -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            // Avatar Image View
            NavigationLink {
//                UserScreen(initialUserData: entry.author, userResult: nil)
            } label: {
                AsyncImage(url: URL(string: entry.author.image)) { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.top, 64)
                } placeholder: {
                    ProgressView()
                }
            }
            
            // Wisp
            VStack(alignment: .leading, spacing: 8) {
                HStack() {
                    AsyncImage(url: URL(string: entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "600").replacingOccurrences(of: "{h}", with: "600") ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(radius: 4)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Text(entry.sound.appleData?.name ?? "")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.secondary)
                        .lineLimit(1)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(UIColor.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    Spacer()
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white)
                        .frame(width: 32, height: 32)
                        .background(Color(UIColor.systemGray5))
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                .overlay(
                    Circle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 12, height: 12)
                        .offset(x: 4, y: -4),
                    alignment: .bottomLeading
                )
                .overlay(
                    Circle()
                        .fill(Color(uiColor: .systemGray6))
                        .frame(width: 6, height: 6)
                        .offset(x: -2, y: 2),
                    alignment: .bottomLeading
                )
                
                Text(entry.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .contextMenu {
                        Menu {
                            Button() {
                                // Flag functionality
                            } label: {
                                Label("Spam", systemImage: "exclamationmark.triangle")
                            }
                        } label: {
                            Label("Flag", systemImage: "flag")
                        }
                        
//                        if entry.author.id == userId {
//                            Menu {
//                                Button(role: .destructive) {
//                                    Task {
//                                        await onDelete(entry.id)
//                                    }
//                                } label: {
//                                    Label("Confirm deletion", systemImage: "checkmark")
//                                }
//                            } label: {
//                                Label("Delete", systemImage: "trash.fill")
//                            }
//                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }
}

