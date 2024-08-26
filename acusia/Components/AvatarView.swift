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
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
            } placeholder: {
                Circle()
                    .fill(Color.gray)
                    .frame(width: size, height: size)
            }
        }
    }
}
