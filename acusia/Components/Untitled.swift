import SwiftUI

struct GradientTextView: View {
    @State private var hue: Double = 203.0
    @State private var intensity: Double = 3.0
    @State private var opacity: Double = 0.2
    @State private var fontSize: CGFloat = 29.0
    @State private var enableAnimation: Bool = false
    @State private var useOverlayBlendMode: Bool = true

    var gradientBackground: LinearGradient {
        let color = Color(hue: hue / 360, saturation: 0.2, brightness: 1.0)
        return LinearGradient(gradient: Gradient(colors: [color.opacity(0.1), color.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                gradientBackground
                    .edgesIgnoringSafeArea(.all) // Full background

                ForEach(0..<Int(intensity), id: \.self) { _ in
                    Text("The art of conversation flourished in the small, bustling café where people from all walks of life gathered to share stories, ideas, and laughter. Sunlight streamed through the large windows, casting warm, golden hues on the")
                        .font(.system(size: fontSize))
                        .foregroundColor(Color(hue: hue / 360, saturation: 0.4, brightness: 1.0))
                        .opacity(opacity)
                        .blendMode(useOverlayBlendMode ? .overlay : .normal)
                        .animation(enableAnimation ? .easeInOut(duration: 0.3) : .none, value: hue)
                        .padding()
                }
            }

            VStack(spacing: 10) {
                HStack {
                    Text("Hue").foregroundColor(.black)
                    Slider(value: $hue, in: 0...360)
                        .accentColor(.blue)
                    Text("\(Int(hue))°").foregroundColor(.black)
                }
                .padding()

                HStack {
                    Text("Intensity").foregroundColor(.black)
                    Slider(value: $intensity, in: 0...5, step: 1)
                        .accentColor(.blue)
                    Text("\(Int(intensity))").foregroundColor(.black)
                }
                .padding()

                HStack {
                    Text("Opacity").foregroundColor(.black)
                    Slider(value: $opacity, in: 0...1)
                        .accentColor(.blue)
                    Text(String(format: "%.2f", opacity)).foregroundColor(.black)
                }
                .padding()

                HStack {
                    Text("Font Size").foregroundColor(.black)
                    Slider(value: $fontSize, in: 10...50)
                        .accentColor(.blue)
                    Text("\(Int(fontSize)) pt").foregroundColor(.black)
                }
                .padding()

                Toggle("Enable Animation", isOn: $enableAnimation)
                    .foregroundColor(.black)
                    .padding()

                Toggle("Use Overlay Blend Mode", isOn: $useOverlayBlendMode)
                    .foregroundColor(.black)
                    .padding()
            }
            .background(Color.white)
            .cornerRadius(10)
            .padding()
        }
        .background(Color.white) // Ensure background is white
    }
}

struct GradientTextView_Previews: PreviewProvider {
    static var previews: some View {
        GradientTextView()
    }
}
