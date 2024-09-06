//
//  entrypreview.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//

import MusicKit
import SwiftUI
import BigUIPaging

struct EntryPreview: View {
    var body: some View {
        let imageUrl = "https://is1-ssl.mzstatic.com/image/thumb/Music4/v4/6a/54/13/6a54138c-e296-88d5-0449-96647323b873/cover.jpg/600x600bb.jpg"

        ScrollView {
            VStack(spacing: 24) {
                // Entry
                VStack(alignment: .leading) {

                    // Avatar, Text, and Thread Line
                    HStack(alignment: .bottom, spacing: 12) {
                        AvatarView(size: 36, imageURL: "https://i.pinimg.com/474x/98/85/c1/9885c1779846521a9e7aad8de50ac015.jpg")
                        
                        CardPreview()
                            .frame(width: 204, height: 280)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 24)
            }
        }
    }
}

struct CardPreview: View {
    @Namespace private var namespace
//    let entry: APIEntry
    @State private var selection: Int = 1
    let imageUrl = "https://is1-ssl.mzstatic.com/image/thumb/Music4/v4/6a/54/13/6a54138c-e296-88d5-0449-96647323b873/cover.jpg/600x600bb.jpg"
    
    var body: some View {
        VStack {
            // Use ForEach with a collection of identifiable data
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        Rectangle()
                            .foregroundStyle(.ultraThickMaterial)
                            .background(
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                            )
                            .overlay(alignment: .topLeading) {
                                VStack(alignment: .leading) {
                                    Text("It's such an abstract and off-kilter sound that I could hardly see having produced widespread ripples at the time of its release. ")
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .semibold))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading) {
                                        Text("Women")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 11, weight: .semibold))
                                        
                                        Text("Public Strain")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 11, weight: .semibold))
                                    }
                                }
                                .padding(20)
                            }
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .background(
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                            )
                    }
                }
            }
            .pageViewStyle(.customCardDeck)
            .pageViewCardCornerRadius(32.0)
            .pageViewCardShadow(.visible)
        }
    }
    
    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}


#Preview {
    EntryPreview()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

struct CustomArtwork {
    let urlFormat: String
    let maximumWidth: Int
    let maximumHeight: Int
    let backgroundColor: CGColor
    let primaryTextColor: CGColor
    let secondaryTextColor: CGColor
    let tertiaryTextColor: CGColor
    let quaternaryTextColor: CGColor
}
