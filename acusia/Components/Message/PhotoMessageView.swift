//
//  PhotoMessageView.swift
//  acusia
//
//  Created by decoherence on 12/8/24.
//
import SwiftUI
import BigUIPaging

struct PhotoMessageView: View {
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

struct PhotoMessagesView: View {
    let photos: [PhotoAttachment]
    private let scaleFactor: CGFloat = 0.9

    var body: some View {
        VStack(alignment: .leading, spacing: -40) {
            ForEach(Array(photos.prefix(3).enumerated()), id: \.element.id) { index, photo in
                let originalWidth: CGFloat = min(CGFloat(photo.width), 196)
                let originalHeight: CGFloat = min(CGFloat(photo.height), originalWidth * 4 / 3)
                let scaledWidth = originalWidth * scaleFactor
                let scaledHeight = originalHeight * scaleFactor

                AsyncImage(url: URL(string: photo.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: scaledWidth, height: scaledHeight)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .frame(width: scaledWidth, height: scaledHeight)
                        .clipped()
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .rotationEffect(rotationAngle(for: index, totalPhotos: photos.count))
                .padding(.leading, leadingPadding(for: index, totalPhotos: photos.count, width: scaledWidth))
                .shadow(radius: 8)
            }
        }
    }

    private func rotationAngle(for index: Int, totalPhotos: Int) -> Angle {
        if totalPhotos == 2 {
            return index.isEven ? .degrees(1) : .degrees(-1)
        } else {
            return index.isEven ? .degrees(-1) : .degrees(1)
        }
    }

    private func leadingPadding(for index: Int, totalPhotos: Int, width: CGFloat) -> CGFloat {
        if totalPhotos == 2 {
            return index == 1 ? width * 0.3 : 0
        } else {
            return index.isEven ? width * 0.3 : 0
        }
    }
}

struct PhotoMessagesDeckView: View {
    let photos: [PhotoAttachment]
    private let scaleFactor: CGFloat = 0.8
    
    @State private var selection: Int = 1
    
    var body: some View {
        PageView(selection: $selection) {
            ForEach(1...3, id: \.self) { index in
                let photo = photos[index - 1]
                
                AsyncImage(url: URL(string: photo.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .clipped()
                }
                .frame(width: 240, height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .pageViewStyle(.customCardDeck)
        .pageViewCardShadow(.visible)
        .frame(width: 240, height: 320)
        
    }
}
