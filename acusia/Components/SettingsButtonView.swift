//
//  SettingsButtonView.swift
//  acusia
//
//  Created by decoherence on 9/14/24.
//

import SwiftUI

struct SettingsButtonView: View {
    @State private var showSettings = false
    
    var body: some View {
        // Settings Button
        Menu {
            Menu("Data") {
                Section("Permanently erase user data from the heavens.") {
                    Button(role: .destructive) {
                        // Action for "Add to Favorites"
                    } label: {
                        Label("Delete", systemImage: "xmark.icloud.fill")
                    }
                }
                
                Section("Temporarily disable user in the heavens.") {
                    Button {
                        // Action for "Add to Favorites"
                    } label: {
                        Label("Archive", systemImage: "exclamationmark.icloud.fill")
                    }
                }
                
                Section("Download user data from the heavens.") {
                    Button {
                        // Action for "Add to Favorites"
                    } label: {
                        Label("Export", systemImage: "icloud.and.arrow.down.fill")
                    }
                }
            }
            Section("System") {
                Button {
                    // Action for "Add to Bookmarks"
                } label: {
                    Label("Disconnect", systemImage: "person.crop.circle.fill.badge.xmark")
                }
            }
            Section("Identity") {
                Button {
                    // Action for "Add to Favorites"
                } label: {
                    Label("Name", systemImage: "questionmark.text.page.fill")
                }
                Button {
                    // Action for "Add to Bookmarks"
                } label: {
                    Label("Avatar", systemImage: "person.circle.fill")
                }
            }
        } label: {
            Image(systemName: "gear")
                .symbolEffect(.scale, isActive: showSettings)
                .font(.system(size: 20))
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: .circle)
                .contentShape(.circle)
                .foregroundColor(.white)
                .symbolRenderingMode(.multicolor)
        }
    }
}
