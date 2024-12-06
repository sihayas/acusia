//
//  MessageView.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//

import SwiftUI

struct MessageView: View {
    @State private var attachmentSize: CGSize = .zero
    @State private var textBubbleSize: CGSize = .zero
    @State private var verticalSpacing: CGFloat = 0
    
    let entity: Entity
    let blipXOffset: CGFloat = 92
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .bottom, spacing: -blipXOffset) {
                TextBubbleView(entity: entity)
                    .alignmentGuide(VerticalAlignment.bottom) { _ in 8 }
                    .measure($textBubbleSize)
                    .padding(.bottom, 4)

                BlipView()
            }
            .onChange(of: textBubbleSize.width) {
                /// If the width of the top is greater than the width of the text bubble minus 16, push the top down.
                verticalSpacing = attachmentSize.width > (textBubbleSize.width - blipXOffset) ? 0 : 24
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entity.username)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(.leading, 12)

                if let song = entity.getSongAttachment() {
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

                        VStack(alignment: .leading, spacing: 4) {
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
                                    .foregroundColor(.white)

                                Text("Music")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.white)
                            }
                        }
                        .blendMode(.difference)
                        
                        Button(action: {
                            // Play song
                        }) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 27))
                                .foregroundColor(.white)
                        }
                        .blendMode(.difference)
                    }
                    .padding(12)
                    .frame(height: 72, alignment: .leading)
                    .background(Color(hex: song.color), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .alignmentGuide(VerticalAlignment.top) { d in d.height - verticalSpacing }
            .measure($attachmentSize)
        }
    }
}
