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
    @State private var isPressed: Bool = false

    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.8 : 1)
                .animation(.bouncy, value: isPressed)
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Circle()
                .fill(Color.gray)
                .frame(width: size, height: size)
                .scaleEffect(isPressed ? 0.8 : 1)
                .animation(.bouncy, value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
