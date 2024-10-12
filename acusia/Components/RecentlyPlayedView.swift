//
//  RecentlyPlayedView.swift
//  acusia
//
//  Created by decoherence on 8/30/24.
//
import SwiftUI
import MusicKit

struct RecentlyPlayedList: View {
    @Binding var isVisible: Bool
    var songs: [SongModel]
    
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(songs.prefix(16).indices, id: \.self) { index in
                if isVisible { // Only render the cell if isVisible is true
                    RecentlyPlayedCell(
                        song: songs[index],
                        isVisible: isVisible,
                        index: index,
                        totalItems: songs.count,
                        animation: animation
                    )
                }
            }
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isVisible) { _, newValue in
            withAnimation {
                isVisible = newValue
            }
        }
    }
}

// MARK: Notification Cell
struct RecentlyPlayedCell: View {
    let song: SongModel
    let isVisible: Bool
    let index: Int
    let totalItems: Int
    
    var animation: Namespace.ID
    
    var body: some View {
        HStack {
            if let artwork = song.artwork {
                ArtworkImage(artwork, width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            
            Text(song.title) // Display the song title
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .matchedGeometryEffect(id: index, in: animation)
        .transition(.blurReplace.animation(
            .spring(response: 0.4, dampingFraction: 0.7)
                .delay(Double(totalItems - index - 1) * 0.01)
        ))
    }
}
