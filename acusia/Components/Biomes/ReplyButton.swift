//
//  ReplyButton'.swift
//  acusia
//
//  Created by decoherence on 12/11/24.
//
import SwiftUI

struct ReplyButton: View {
    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            // Perform button action here
        } label: {
            Image(systemName: "message.badge.fill")
                .fontWeight(.bold)
                .font(.footnote)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    TintedBlurView(style: .systemChromeMaterialLight, backgroundColor: .black, blurMutingFactor: 0.75)
                )
                .clipShape(Circle())
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
