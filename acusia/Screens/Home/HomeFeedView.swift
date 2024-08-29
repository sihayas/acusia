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
                ForEach(viewModel.entries.indices, id: \.self) { index in
                    let entry = viewModel.entries[index]
                    Entry(
                        entry: entry,
                        onDelete: deleteEntry
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollClipDisabled(true)
        .onAppear { Task { await viewModel.fetchEntries() } }
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
