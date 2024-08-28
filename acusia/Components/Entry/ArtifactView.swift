import SwiftUI

struct ArtifactView: View {
    @State private var start = Date()
    @Binding var isVisible: Bool

    // State to hold the measured size of the VStack
    @State private var contentSize: CGSize = .zero

    @State private var animateScale = false
    @State private var animateOffset = false
    @State private var randomOffset: Float = .random(in: 0 ..< 2 * .pi)

    @State private var isPresented = false

    var entry: APIEntry? = nil

    var body: some View {
        TimelineView(.animation) { timeline in
            let text = entry?.text ?? "Hello, world"
            let imageUrl = entry?.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"
            let time = start.distance(to: timeline.date)
            
            let width: CGFloat = 164
            let height: CGFloat = 164


            // White fill for the mask/canvas effect to work.
            let gooeyView =
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.clear)
                        .frame(width: width, height: height)

                    Text(text)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.black, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .scaleEffect(animateScale ? 1 : 0, anchor: .top)
                        .offset(y: animateOffset ? 0 : -48)
                }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding([.leading], 12)
                .padding([.bottom], 4)

            ZStack {
                // MARK: Measure size of the view.

                gooeyView
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                contentSize = geometry.size
                            }
                        }
                    )

                // MARK: Gooey Effect Underlay

                if contentSize != .zero {
                    // First draw the shapes. The canvas/symbols are overlayed and used as a mask
                    // because the iridescent shader + the alpha threshold wouldnt work otherwise.
                    gooeyView
                        .hidden()
                        .overlay(
                            Canvas(opaque: false, colorMode: .nonLinear, rendersAsynchronously: false) { ctx, size in
                                let bounds = CGRect(origin: .zero, size: size)
                                // Drawing the symbol: apply blur and alpha threshold filters
                                // Alpha filter will make the view black, so we use it as a mask and fill bounds with foreground style
                                ctx.clipToLayer { ctx in
                                    ctx.addFilter(.alphaThreshold(min: 0.5))
                                    ctx.addFilter(.blur(radius: 4))

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
                            // Bubble tail
                            ZStack(alignment: .bottomLeading) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 12)
                                    .offset(x: 12, y: -4)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 4, y: -2)
                            },
                            alignment: .bottomLeading
                        )
                        .colorEffect(
                            // Iridescent effect
                            ShaderLibrary.iridescent(
                                .float(time),
                                .float(randomOffset)
                            )
                        )
                        .overlay(
                            // Content itself
                            VStack(alignment: .leading, spacing: 8) {
                                // Art
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(.clear)
                                    .frame(width: width, height: height)
                                    .overlay(
                                        VStack(alignment: .leading) {
                                            AsyncImage(url: URL(string: imageUrl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .mask(
                                                        Image("mask")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    )
                                                    .overlay(
                                                        Image("heartbreak")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 24, height: 24)
                                                            .foregroundColor(.white)
                                                            .rotationEffect(.degrees(6))
                                                            .padding(8)
                                                        ,
                                                        alignment: .bottomLeading
                                                    )
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 24)
                                                    .fill(.gray)
                                                    .aspectRatio(contentMode: .fit)
                                            }
                                        }
                                        .frame(width: width, height: height, alignment: .topLeading)
                                        ,
                                        alignment: .topLeading
                                    )
                                
                                Text(text)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .scaleEffect(animateScale ? 1 : 0, anchor: .top)
                                    .offset(y: animateOffset ? 0 : -48)
                            }
                            .frame(maxWidth: .infinity, alignment: .bottomLeading)
                            .padding([.leading], 12)
                            .padding([.bottom], 4)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: isVisible) { _, _ in
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0)) {
                    animateScale = true
                }
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0)) {
                    animateOffset = true
                }
            }
        }
    }
}

#Preview {
    ArtifactView(isVisible: .constant(true))
        .background(Color.black)
}
