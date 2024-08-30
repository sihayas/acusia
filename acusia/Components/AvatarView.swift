//
//  AvatarView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import SwiftUI

struct AvatarView: View {
    let size: CGFloat
    let imageURL: String

    var body: some View {
        NavigationLink(destination: EmptyView()) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .frame(width: size, height: size)
                    .mask(
                        Image("mask_avatar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
                    .overlay(
                        AvatarPath()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: size, height: size)
                    )
            } placeholder: {
                Circle()
                    .fill(Color.gray)
                    .frame(width: size, height: size)
            }
        }
    }
}
