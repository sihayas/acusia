import SwiftUI

struct GooeyArtifactView: View {
    @State private var start = Date()
    @Binding var isVisible: Bool

    // State to hold the measured size of the VStack
    @State private var contentSize: CGSize = .zero

    @State private var animateScale = false
    @State private var animateOffset = false
    @State private var randomOffset: Float = .random(in: 0 ..< 2 * .pi)
    
    @State private var isContextMenuOpen = false

    var entry: APIEntry? = nil

    var body: some View {
        let text = entry?.text ?? "Hello, world"
        let imageUrl = entry?.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"

        TimelineView(.animation) { timeline in
            let time = start.distance(to: timeline.date)
            
            let gooeyView =
            // White fill for the mask/canvas effect to work.
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .frame(width: 216, height: 216)

                Text(text)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .scaleEffect(animateScale ? 1 : 0, anchor: .topLeading)
                    .offset(y: animateOffset ? 0 : -16)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 56, height: 56)
                            .offset(x: 0, y: isContextMenuOpen ? -48 : 0),
                        alignment: .topTrailing
                    )
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding([.leading, .bottom], 12)

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
                .opacity(0)
                .allowsHitTesting(false)

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
                            // Bubble tail
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
                            // Iridescent effect
                            ShaderLibrary.iridescent(
                                .float(time),
                                .float(randomOffset)
                            )
                        )
                        .overlay (
                            // Content itself
                            VStack(alignment: .leading, spacing: 12) {
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(.clear)
                                    .frame(width: 216, height: 216)
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
                                                    .padding(1)
                                            } placeholder: {
                                                ProgressView()
                                            }

                                            Image("heartbreak")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32, height: 32)
                                                .foregroundColor(.white)
                                                .padding(16)
                                                .rotationEffect(.degrees(6))
                                                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                                        }
                                    )

                                Text(text)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .scaleEffect(animateScale ? 1 : 0, anchor: .topLeading)
                                    .offset(y: animateOffset ? 0 : -16)
                            }
                            .frame(maxWidth: .infinity, alignment: .bottomLeading)
                            .padding([.leading, .bottom], 12)
                        )
                        .contextMenu {
                            Button {
                                print("Change country setting")
                            } label: {
                                Label("Choose Country", systemImage: "globe")
                            }
                        }
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                            withAnimation {
                                isContextMenuOpen.toggle()
                            }
                            print("Opened")
                        })

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

#Preview {
    GooeyArtifactView(isVisible: .constant(true))
        .background(Color.black)
}
