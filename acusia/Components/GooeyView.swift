//
//  GooeyView.swift
//  acusia
//
//  Created by decoherence on 8/18/24.
//

import SwiftUI

struct GooeyView: View {
    @State private var offset: CGSize = .zero
    private let circleDiameter = 90.0
    private let deviceWidth = UIScreen.main.bounds.width
    private let deviceHeight = UIScreen.main.bounds.height
    
    private var initialX: Double {
        deviceWidth / 2.0
    }
    
    private var initialY: Double {
        deviceHeight / 2.0
    }
    
    var body: some View {
        ZStack {
            Canvas { context, _ in
                let textBubble = context.resolveSymbol(id: 0)!
//                let artifactCard = context.resolveSymbol(id: 1)!
                
                // The core of the effect is essentially blurring the shapes
                // and then applying an alpha threshold which bumps the opacity
                // of the parts of the shape that have been blurred below the
                // threshold to 1, creating the gooey effect.
//                context.addFilter(.alphaThreshold(min: 0.5, color: .black))
//                context.addFilter(.blur(radius: 6))
                
                context.drawLayer { ctx in
                    ctx.draw(textBubble, at: CGPoint(x: initialX, y: initialY))
//                    ctx.draw(artifactCard, at: CGPoint(x: initialX, y: initialY))
                }
            } symbols: {
                VStack(alignment: .leading, spacing: 16) {
                    RoundedRectangle(cornerRadius: 32)
                        .frame(width: 196, height: 196)
                    Text("hihihihihihihihihihihihihi")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    EmptyView()
                }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding()
                .border(Color.blue, width: 4)
                .offset(x: offset.width, y: offset.height)
                .tag(0)
            }
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
            
            // Content Overlay
            // Because of the blur of the blob effect, content needs to be rendered 1:1
            // on top of the gooey effect shapes. The shapes in the canvas will take care of
            // the gooey effect, while the shapes here will serve as the frame/overlay.
//            RoundedRectangle(cornerRadius: 32)
//                .fill(Color.clear)
//                .frame(width: 196, height: 196)
//                .border(Color.green, width: 1)
//                .offset(x: offset.width, y: offset.height)
//                .allowsHitTesting(false)
//            
//            Text("hi there hi there hi there hi there hi there")
//                .font(.system(size: 16, weight: .regular))
//                .foregroundColor(.white)
//                .padding(.horizontal, 14)
//                .padding(.vertical, 10)
//                .border(Color.green, width: 1)
//                .background(.clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .frame(width: .infinity, height: .infinity)
        .background(Color.white)
        .border(Color.red, width: 1)
    }
}

#Preview {
    GooeyView()
}
