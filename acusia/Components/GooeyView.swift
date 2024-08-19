//
//  GooeyView.swift
//  acusia
//
//  Created by decoherence on 8/18/24.
//

import SwiftUI

struct GooeyView: View {
    @State private var offset: CGSize = .zero
    @State private var contentSize: CGSize = .zero // State to hold the measured size of the VStack

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.clear)
                    .frame(width: 196, height: 196)
                Text("Very reminiscent of The Ascension if I'm being entirely honest, primarily in that it feels equal parts trailblazing and perplexing.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
//                    .background(.clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .offset(x: offset.width, y: offset.height)
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(24)
            .background(
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        contentSize = geometry.size
                        print("contentSize: \(contentSize)")
                    }
                }
            )
            .allowsHitTesting(false)
            .zIndex(1)
            .tag(0)

            if contentSize != .zero {
                Canvas { context, _ in
                    // Link the "symbol" by id + tag.
                    let container = context.resolveSymbol(id: 0)!

                    // The core of the effect is essentially blurring the shapes
                    // and then applying an alpha threshold which bumps the opacity
                    // of the parts of the shape that have been blurred below the
                    // threshold to 1, creating the gooey effect.
                    context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                    context.addFilter(.blur(radius: 6))

                    context.drawLayer { ctx in
                        ctx.draw(container, at: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2))
                    }
                } symbols: {
                    VStack(alignment: .leading, spacing: 16) {
                        RoundedRectangle(cornerRadius: 32)
                            .frame(width: 196, height: 196)
                        Text("Very reminiscent of The Ascension if I'm being entirely honest, primarily in that it feels equal parts trailblazing and perplexing.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .offset(x: offset.width, y: offset.height)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding(24)
                    .tag(0)
                }
                .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
                .border(Color.red, width: 2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.spring()) {
                                offset = value.translation
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                )
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .border(Color.black, width: 1)
    }
}

#Preview {
    GooeyView()
}
