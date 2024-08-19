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

    @State private var animateScale = false
    @State private var animateOffset = false

    @Binding var animate: Bool

    var entry: APIEntry? = nil

    var body: some View {
        let text = entry?.text ?? ""
        let imageUrl = entry?.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? ""

        ZStack {
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.clear)
                    .frame(width: 196, height: 196)
                    .overlay(
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .mask(
                                        Image("mask")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    )
                                    .shadow(color: .black.opacity(0.7), radius: 16, x: 0, y: 4)
                            } placeholder: {
                                ProgressView()
                            }

                            Image("heartbreak")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .foregroundColor(.black)
                                .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 4)
                                .padding(8)
                                .rotationEffect(.degrees(6))
                        }
                        .padding(8)
                    )
                Text(text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .scaleEffect(animateScale ? 1.0 : 0, anchor: .topLeading)
                    .offset(y: animateOffset ? 0 : -80)
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(12)
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
            .onChange(of: animate) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0)) {
                        animateScale = true
                    }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.4, blendDuration: 0)) {
                        animateOffset = true
                    }
                }
            }

            if contentSize != .zero {
                Canvas { context, _ in
                    let container = context.resolveSymbol(id: 0)!

                    context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                    context.addFilter(.blur(radius: 6))

                    context.drawLayer { ctx in
                        ctx.draw(container, at: CGPoint(x: contentSize.width / 2, y: contentSize.height / 2))
                    }
                } symbols: {
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.black)
                            .frame(width: 196, height: 196)
                        Text(text)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .scaleEffect(animateScale ? 1.0 : 0, anchor: .topLeading)
                            .offset(y: animateOffset ? 0 : -80)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding(12)
                    .tag(0)
                }
                .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
            }
        }
        .background(Color.black)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

// #Preview {
//    HStack {
//        Circle()
//            .frame(width: 80, height: 80)
//        GooeyView()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black)
//    }
// }
