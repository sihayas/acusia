//
//  SongMessageView.swift
//  acusia
//
//  Created by decoherence on 1/23/25.
//

import SwiftUI

struct SongAttachmentView: View {
    let song: SongAttachment

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: song.artwork)) { image in
                image
                    .resizable()
            } placeholder: {
                Rectangle()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .aspectRatio(contentMode: .fit)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                VStack(alignment: .leading) {
                    Text(song.artistName)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                    Text(song.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    Text("Music")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            .blendMode(.difference)

            Button(action: {
                // Play song
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.secondary)
            }
            .blendMode(.difference)
        }
        .padding(12)
        .frame(height: 72, alignment: .leading)
        .background(Color(hex: song.color), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
