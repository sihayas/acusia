//
//  PhotoMessageView.swift
//  acusia
//
//  Created by decoherence on 12/8/24.
//
import SwiftUI

/// One Photo
struct PhotoAttachmentView: View {
    let photo: PhotoAttachment

    var body: some View {
        let maxWidth: CGFloat = 196
        let maxHeight: CGFloat = maxWidth * 4 / 3
        let aspectRatio = CGFloat(photo.width) / CGFloat(photo.height)
        let displayedWidth = min(CGFloat(photo.width), maxWidth)
        let displayedHeight = min(CGFloat(photo.height), maxHeight)

        AsyncImage(url: URL(string: photo.url)) { image in
            image
                .resizable()
                .aspectRatio(aspectRatio, contentMode: .fill)
                .frame(width: displayedWidth, height: displayedHeight)
                .clipped()
        } placeholder: {
            Rectangle()
                .frame(width: displayedWidth, height: displayedHeight)
                .clipped()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
