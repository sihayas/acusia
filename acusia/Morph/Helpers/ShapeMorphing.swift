//
//  ShapeMorphing.swift
//  GooeyShareButton
//
//  Created by Leandro Bastos on 13/06/23.
//

import SwiftUI

struct ShapeMorphing: View {
    var color: Color = .white
    var duration: CGFloat = 0.5

    @State private var radius: CGFloat = 0
    @State private var animatedRadiusValue: CGFloat = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            Canvas { ctx, size in
                ctx.addFilter(.alphaThreshold(min: 0.5, color: color))
                ctx.addFilter(.blur(radius: animatedRadiusValue))

                ctx.drawLayer { ctx1 in
                    if let resolvedImageView = ctx.resolveSymbol(id: 0) {
                        ctx1.draw(resolvedImageView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                    }
                }
            }
        }
        .animationProgress(endValue: radius) { value in
            animatedRadiusValue = value

            if value >= 6 {
                withAnimation(.linear(duration: duration).speed(2)) {
                    radius = 0
                }
            }
        }
//        .border(Color.green, width: 1)
    }
}

//struct ShapeMorphing_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
