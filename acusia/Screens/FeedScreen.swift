//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//
import SwiftUI
import Combine


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
                                userId: userId,
                                entry: entry,
                                namespace: ns,
                                scrolledEntryID: scrolledEntryID,
                                onDelete: deleteEntry
                            )
                        } else {
                            Artifact(
                                userId: userId,
                                entry: entry,
                                namespace: ns,
                                scrolledEntryID: scrolledEntryID,
                                expandedEntryID: $expandedEntryID,
                                onDelete: deleteEntry
                            )
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
                setupNavigationBar()
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
                            ATextCard(entry: expandedEntry, namespace: ns)
                            .zIndex(1)
                            .padding(.bottom, 16)
                            .rotationEffect(.degrees(-2))
                            ASoundCard(entry: expandedEntry, namespace: ns)
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
            if response.success {
                print("Entry deleted successfully")
                DispatchQueue.main.async {
                    self.viewModel.removeEntry(id: id)
                }
            } else {
                print("Failed to delete entry")
            }
        } catch {
            deleteError = error
        }
    }
}


struct ATextCard: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(UIColor.systemGray6))
            .frame(width: 216, height: 304)
            .shadow(radius: 8)
            .overlay(
                Text(entry.text)
                    .foregroundColor(Color.white)
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(width: 216, height: 304, alignment: .topLeading)
            )
            .matchedGeometryEffect(id: "textCard_\(entry.id)", in: namespace)
    }
}

struct ASoundCard: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(UIColor.systemGray6))
            .frame(width: 216, height: 304)
            .shadow(radius: 8)
            .overlay(
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
                        SoundScreen(sound: entry.sound.appleData!)
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
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(width: 216, height: 304, alignment: .trailing)
            )
            .matchedGeometryEffect(id: "soundCard_\(entry.id)", in: namespace)
    }
}

struct Artifact: View {
    @EnvironmentObject private var navManager: NavManager
    let userId: String
    let entry: APIEntry
    var namespace: Namespace.ID
    let scrolledEntryID: APIEntry.ID?
    @Binding var expandedEntryID: APIEntry.ID?
    let onDelete: (String) async -> Void
    
    @State private var isSheetPresented = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: entry.sound.appleData?.artworkBgColor ?? ""))
                .frame(maxWidth: UIScreen.main.bounds.width / 2, maxHeight: UIScreen.main.bounds.width / 2)
                .blur(radius: 164)
            
            VStack(alignment: .leading) {
                Text(entry.author.username)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 64)
                    .padding(.bottom, 4)
                HStack(alignment: .top, spacing: 8) {
                    NavigationLink {
                        UserScreen(initialUserData: entry.author, userResult: nil)
                            .navigationTransition(.zoom(sourceID: entry.id, in: namespace))
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
                    
                    VStack(alignment: .leading, spacing: -56) {
                        // MARK: Sound Card View
                        if expandedEntryID != entry.id {
                            ASoundCard(entry: entry, namespace: namespace)
                                .overlay(
                                    HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                                        .offset(x: 20, y: -20),
                                    alignment: .topTrailing
                                )
                                .overlay(
                                    FlameTap(isTapped: entry.isHeartTapped, count: entry.flameCount)
                                        .offset(x: 24, y: 64),
                                    alignment: .topTrailing
                                )
                                .rotationEffect(.degrees(2), anchor: .topTrailing)
                        }
                        
                        HStack {
                            Spacer()
                            // MARK: Text Card View
                            if expandedEntryID != entry.id {
                                ATextCard(entry: entry, namespace: namespace)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            expandedEntryID = entry.id
                                            isSheetPresented = true
                                        }
                                    }
                                    .contextMenu {
                                        Menu {
                                            Button() {
                                                // Flag functionality
                                            } label: {
                                                Label("Spam", systemImage: "exclamationmark.triangle")
                                            }
                                        } label: {
                                            Label("Flag", systemImage: "flag.fill")
                                        }
                                        
                                        if entry.author.id == userId {
                                            Menu {
                                                Button(role: .destructive) {
                                                    Task {
                                                        await onDelete(entry.id)
                                                    }
                                                } label: {
                                                    Label("Confirm deletion", systemImage: "checkmark")
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
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
                VStack {
                    
                }
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(32)
                .presentationBackground(.thinMaterial)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .onWillDisappear {
                    navManager.isViewingEntry = false
                    withAnimation(.spring()) {
                        expandedEntryID = nil
                    }
                }
                .onAppear {
                    navManager.isViewingEntry = true
                }
            }
        }
    }
}


struct Wisp: View {
    @EnvironmentObject private var navManager: NavManager
    let userId: String
    let entry: APIEntry
    var namespace: Namespace.ID
    let scrolledEntryID: APIEntry.ID?
    let onDelete: (String) async -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            // Avatar Image View
            NavigationLink {
                UserScreen(initialUserData: entry.author, userResult: nil)
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
                        
                        if entry.author.id == userId {
                            Menu {
                                Button(role: .destructive) {
                                    Task {
                                        await onDelete(entry.id)
                                    }
                                } label: {
                                    Label("Confirm deletion", systemImage: "checkmark")
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }
}

extension FeedScreen {
    private func setupNavigationBar() {
        var backButtonBackgroundImage = UIImage(systemName: "chevron.left.circle.fill")!
        backButtonBackgroundImage = backButtonBackgroundImage.applyingSymbolConfiguration(.init(paletteColors: [.white, .darkGray]))!
        UINavigationBar.appearance().backIndicatorImage = backButtonBackgroundImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonBackgroundImage
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = .clear
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000.0, vertical: 0.0), for: .default)
    }
}

private struct WillDisappearHandler: UIViewControllerRepresentable {

    let onWillDisappear: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        ViewWillDisappearViewController(onWillDisappear: onWillDisappear)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private class ViewWillDisappearViewController: UIViewController {
        let onWillDisappear: () ->   Void

        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

extension View {
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        background(WillDisappearHandler(onWillDisappear: perform))
    }
}
