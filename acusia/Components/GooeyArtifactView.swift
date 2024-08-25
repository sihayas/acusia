import SwiftUI

struct GooeyArtifactView: View {
    @State private var start = Date()
    @Binding var isVisible: Bool

    // State to hold the measured size of the VStack
    @State private var contentSize: CGSize = .zero
    
    @State private var artViewSize: CGSize = .zero
    @State private var textViewSize: CGSize = .zero

    @State private var animateScale = false
    @State private var animateOffset = false
    @State private var randomOffset: Float = .random(in: 0 ..< 2 * .pi)
    
    @State private var isPresented = false
    @State private var selectedEmoji: Emoji? = nil

    var entry: APIEntry? = nil

    var body: some View {
        let text = entry?.text ?? "Hello, world"
        let imageUrl = entry?.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"

        TimelineView(.animation) { timeline in
            let time = start.distance(to: timeline.date)
            
            let artView = 
            // Content itself
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.white)
                    .frame(width: 216, height: 216)
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding([.leading, .bottom], 12)
            
            let textView =
            VStack(alignment: .leading, spacing: 12) {
                Text(text)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .scaleEffect(animateScale ? 1 : 0, anchor: .topLeading)
                    .offset(y: animateOffset ? 0 : -16)
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding([.leading, .bottom], 12)

            ZStack {
                // MARK: Measure size of the view.
                textView
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                textViewSize = geometry.size
                            }
                        }
                    )
                    .hidden()
                    .allowsHitTesting(false)
                
                artView
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                artViewSize = geometry.size
                            }
                        }
                    )
                    .hidden()
                    .allowsHitTesting(false)

                // MARK: Gooey Effect Underlay
                if artViewSize != .zero && textViewSize != .zero {
                    // First draw the shapes. The canvas/symbols are overlayed and used as a mask
                    // because the iridescent shader + the alpha threshold wouldnt work otherwise.
                    VStack(alignment: .leading) {
                        artView
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
                                    artView
                                        .tag(0)
                                }
                                    .frame(maxWidth: artViewSize.width, maxHeight: artViewSize.height)
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
                                VStack(alignment: .leading) {
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
                                }
                                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                                    .padding([.leading, .bottom], 12)
                            )
                            .contextMenu {
                                Button("Select Emoji") {
                                    isPresented = true
                                }
                            }
                        
                        textView
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
                                    textView
                                        .tag(0)
                                }
                                    .frame(maxWidth: textViewSize.width, maxHeight: textViewSize.height)
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
                                    Text(text)
                                        .font(.system(size: 15, weight: .semibold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(.clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .scaleEffect(animateScale ? 1 : 0, anchor: .topLeading)
                                        .offset(y: animateOffset ? 0 : -16)
                                }
                                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                                    .padding([.leading, .bottom], 12)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
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

struct Emoji: Identifiable, Equatable {
    let value: Int
    var emojiSting: String {
        guard let scalar = UnicodeScalar(value) else { return "?" }
        return String(Character(scalar))
    }
    var valueString: String {
        String(format: "%x", value)
    }
    
    var id: Int {
        return value
    }
    
    static func examples() -> [Emoji] {
        let values = 0x1f600...0x1f64f
        return values.map {  Emoji(value: $0) }
    }
}

struct EmojiSelectorView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selection: Emoji?
    
    let columns = [GridItem(.adaptive(minimum: 44), spacing: 10)]
    let emojis: [Emoji]  = Emoji.examples()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select an Emoji")
                .font(.title3)
                .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(emojis) { emoji in
                        ZStack {
                            emoji == selection ? Color.blue : Color.clear
                            Text(emoji.emojiSting)
                                .font(.title)
                                .padding(5)
                                .onTapGesture {
                                    selection = emoji
                                    dismiss()
                                }
                        }
                    }
                }.padding()
            }
        }
        .padding(.vertical)
    }
}
