//
//  SearchResultsList.swift
//  acusia
//
//  Created by decoherence on 7/13/24.
//
import SwiftUI

struct SearchResultsList: View {
    @Binding var path: NavigationPath
    @Binding var uiState: UIState
    @Binding var searchText: String
    @Binding var keyboardHeight: CGFloat
    @StateObject private var viewModel = SearchViewModel()
    @StateObject private var navManager = NavManager.shared

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            ForEach(Array(viewModel.searchResults.enumerated().reversed()), id: \.element) { index, result in
                Button(action: {
                    handleResultSelection(result)
                }, label: {
                    SearchResultCell(result: result, index: index, totalCount: viewModel.searchResults.count, showSearchResults: uiState == .searching)
                })
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer().frame(height: keyboardHeight + 96)
        }
        .padding(.leading, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: searchText) { _, newValue in
            Task {
                await viewModel.performSearch(query: newValue)
            }
        }
    }
    
    private func handleResultSelection(_ result: SearchResultItem) {
        switch result {
        case .sound(let sound):
            if sound.type == "albums" {
                // navigate to album page
                path.append(sound)
            } else {
                // play song
                navManager.selectedSound = sound
            }
        case .user(let user):
            path.append(user)
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.8)) {
                // change the UI state to collapsed
            }
        }
        
    }
}

// MARK: Search Result Cell
struct SearchResultCell: View {
    @State private var isVisible = false
    @StateObject private var navManager = NavManager.shared
    
    let result: SearchResultItem
    let index: Int
    let totalCount: Int
    let showSearchResults: Bool
    
    
    var body: some View {
        ZStack {
            HStack {
                AsyncImage(url: result.imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                } placeholder: {
                    Color.clear
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // subtitle for sounds
                    if case .sound(let soundData) = result {
                        HStack(spacing: 0) {
                            Text(result.subtitle)
                            Text(soundData.type == "songs" ? " · Song" : " · Album")
                        }
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    }
 
                    Text(result.title)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                if case .sound(let soundData) = result {
                    if soundData.type == "songs" {
                        // play a song
                        PlayButtonView(songId: soundData.id)
                        Image("bubble")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                            .foregroundColor(.secondary)
                    } else {
                        // create an entry for album
                        Button(action: {
                            navManager.selectedSound = soundData
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white)
                                .frame(width: 28, height: 28)
                                .background(Color(UIColor.systemGray5))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                } else if case .user = result {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundColor(.white)
                        .font(.system(size: 22))
                }
            }
            .padding(.trailing, 16)
        }
        .background(Color(UIColor.systemGray6))
        .frame(width: 296, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .scaleEffect(isVisible ? 1 : 0, anchor: .bottom)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.05), value: isVisible)
        .onAppear {
            if showSearchResults {
                withAnimation(.easeOut(duration: 0.1).delay(Double(index) * 0.05)) {
                    isVisible = true
                }
            }
        }
        .onChange(of: showSearchResults) { _, newValue in
            withAnimation(.easeOut(duration: 0.1).delay(Double(index) * 0.05)) {
                isVisible = newValue
            }
        }
    }
}
