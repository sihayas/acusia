import SwiftUI

struct GooeyView: View {
    @State private var start = Date()
    @Binding var isVisible: Bool

    // State to hold the measured size of the VStack
    @State private var contentSize: CGSize = .zero

    @State private var animateScale = false
    @State private var animateOffset = false
    @State private var randomOffset: Float = Float.random(in: 0..<2 * .pi)

    var entry: APIEntry? = nil

    var body: some View {
        let text = entry?.text ?? "Hello, world"
        let imageUrl = entry?.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"

        TimelineView(.animation) { timeline in
            let time = start.distance(to: timeline.date)

            ZStack {
                // MARK: Content Overlay

                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.clear)
                        .frame(width: 232, height: 232)
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
                                        .padding(8)
                                } placeholder: {
                                    ProgressView()
                                }

                                Image("heartbreak")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.white)
                                    .padding(16)
                                    .rotationEffect(.degrees(6))
                            }
                        )

                    Text(text)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .scaleEffect(animateScale ? 1 : 0, anchor: .top)
                        .offset(y: animateOffset ? 0 : -16)
                }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding(12)
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            contentSize = geometry.size
                        }
                    }
                )
                .zIndex(1)

                // MARK: Gooey Effect Underlay

                if contentSize != .zero {
                    let gooeyView = VStack(alignment: .leading, spacing: 12) {
                                        RoundedRectangle(cornerRadius: 32)
                                            .fill(.white)
                                            .frame(width: 232, height: 232)

                                    
                                        Text(text)
                                            .font(.system(size: 15, weight: .semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .scaleEffect(animateScale ? 1 : 0, anchor: .top)
                                            .offset(y: animateOffset ? 0 : -16)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                                    .padding(12)


                    gooeyView
                        .hidden()
                        .overlay(
                            Canvas(opaque: false, colorMode: .nonLinear, rendersAsynchronously: false) { ctx, size in
                                let bounds = CGRect(origin: .zero, size: size)
                                // Drawing the symbol: apply blur and alpha threshold filters
                                // Alpha filter will make the view black, so we use it as a mask and fill bounds with foreground style
                                ctx.clipToLayer { ctx in
                                    ctx.addFilter(.alphaThreshold(min: 0.5))
                                    ctx.addFilter(.blur(radius: 6))

                                    ctx.drawLayer { ctx in
                                        ctx.draw(ctx.resolveSymbol(id: 0)!, in: bounds)
                                    }
                                }
                                ctx.fill(.init(.init(origin: .zero, size: size)), with: .foreground)
                            } symbols: {
                                gooeyView
                                    .tag(0)
                            }
                            .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
                        )
                        .overlay(
                            ZStack(alignment: .bottomLeading) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 12, y: -12)
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 4, height: 4)
                                    .offset(x: 6, y: -10)
                            },
                            alignment: .bottomLeading
                        )
                        .colorEffect(
                            ShaderLibrary.iridescent(
                                .float(time),
                                .float(randomOffset)
                            )
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: isVisible) { _, _ in
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0)) {
                    animateScale = true
                }
                withAnimation(.spring(response: 1.2, dampingFraction: 1, blendDuration: 0)) {
                    animateOffset = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GooeyView(isVisible: .constant(true))
            .background(Color.black)
//            .background(Color.black)
    }
}
