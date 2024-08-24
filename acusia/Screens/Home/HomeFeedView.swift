//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import Combine
import SwiftUI

struct HomeFeedView: View {
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
    
    let imageURLs = [
        URL(string: "https://picsum.photos/200/300")!,
        URL(string: "https://picsum.photos/200/300")!,
        URL(string: "https://picsum.photos/200/300")!
    ]
    
    // Helper function to calculate balanced offsets
    func tricornOffset(for index: Int) -> CGSize {
        let radius: CGFloat = 9 // Adjusted radius for better spacing
        switch index {
        case 0: // Top Center
            return CGSize(width: 0, height: -radius)
        case 1: // Bottom Left
            return CGSize(width: -radius * cos(.pi / 6), height: radius * sin(.pi / 6))
        case 2: // Bottom Right
            return CGSize(width: radius * cos(.pi / 6), height: radius * sin(.pi / 6))
        default:
            return .zero
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                } else {
                    WispView(entry: entry, namespace: namespace)
                }
            }
            
            HStack {
                RoundedCornerPath()
                    .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 40, height: 40)
                    .overlay(
                        ZStack {
                            ForEach(0..<3) { index in
                                AsyncImage(url: imageURLs[index]) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 12, height: 12)
                                        .clipShape(Circle())
                                        .offset(tricornOffset(for: index))
                                } placeholder: {
                                    EmptyView()
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                    )
                
                Text("33 Chains")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
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
            // Sound attachment
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
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
                Text(entry.sound.appleData?.name ?? "")
                    .lineLimit(1)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.secondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray6))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // Text bubble
            ZStack(alignment: .bottomLeading) {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 12, height: 12)
                    .offset(x: 0, y: 0)
                
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 6, height: 6)
                    .offset(x: -6, y: 4)
                
                Text(entry.text)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .overlay(
                ZStack {
                    HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                        .offset(x: 0, y: -22)
                    FlameTap(isTapped: entry.isFlameTapped, count: entry.flameCount)
                        .offset(x: -52, y: -22)
                },
                alignment: .topTrailing
            )
        }
        .padding([.bottom, .leading], 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct RoundedCornerPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        // Draw the rounded corner curve to the right center
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                          control: CGPoint(x: rect.midX, y: rect.midY))
        
        return path
    }
}
