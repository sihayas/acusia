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
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } placeholder: {
            Circle()
                .fill(Color.gray)
                .frame(width: size, height: size)
        }
    }
}
