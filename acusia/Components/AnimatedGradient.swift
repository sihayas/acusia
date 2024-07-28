import SwiftUI

struct MeshGradientColorMixView: View {
    let hexColor: String
    
    init(hexColor: String = "7DE8D1") {
        self.hexColor = hexColor
    }
    
    var body: some View {
        ZStack {
            MeshGradient(
                width: 9,
                height: 9,
                points: [
                    [0.0, 0.0], [0.125, 0.0], [0.25, 0.0], [0.375, 0.0], [0.5, 0.0], [0.625, 0.0], [0.75, 0.0], [0.875, 0.0], [1.0, 0.0],
                    [0.0, 0.125], [0.125, 0.125], [0.25, 0.125], [0.375, 0.125], [0.5, 0.125], [0.625, 0.125], [0.75, 0.125], [0.875, 0.125], [1.0, 0.125],
                    [0.0, 0.25], [0.125, 0.25], [0.25, 0.25], [0.375, 0.25], [0.5, 0.25], [0.625, 0.25], [0.75, 0.25], [0.875, 0.25], [1.0, 0.25],
                    [0.0, 0.375], [0.125, 0.375], [0.25, 0.375], [0.375, 0.375], [0.5, 0.375], [0.625, 0.375], [0.75, 0.375], [0.875, 0.375], [1.0, 0.375],
                    [0.0, 0.5], [0.125, 0.5], [0.25, 0.5], [0.375, 0.5], [0.5, 0.5], [0.625, 0.5], [0.75, 0.5], [0.875, 0.5], [1.0, 0.5],
                    [0.0, 0.625], [0.125, 0.625], [0.25, 0.625], [0.375, 0.625], [0.5, 0.625], [0.625, 0.625], [0.75, 0.625], [0.875, 0.625], [1.0, 0.625],
                    [0.0, 0.75], [0.125, 0.75], [0.25, 0.75], [0.375, 0.75], [0.5, 0.75], [0.625, 0.75], [0.75, 0.75], [0.875, 0.75], [1.0, 0.75],
                    [0.0, 0.875], [0.125, 0.875], [0.25, 0.875], [0.375, 0.875], [0.5, 0.875], [0.625, 0.875], [0.75, 0.875], [0.875, 0.875], [1.0, 0.875],
                    [0.0, 1.0], [0.125, 1.0], [0.25, 1.0], [0.375, 1.0], [0.5, 1.0], [0.625, 1.0], [0.75, 1.0], [0.875, 1.0], [1.0, 1.0]
                ],
                colors: [
                    color(0.00), color(0.00), color(0.02), color(0.02), color(0.02), color(0.02), color(0.02), color(0.00), color(0.00),
                    color(0.00), color(0.03), color(0.06), color(0.09), color(0.10), color(0.09), color(0.06), color(0.03), color(0.00),
                    color(0.02), color(0.06), color(0.12), color(0.18), color(0.20), color(0.18), color(0.12), color(0.06), color(0.02),
                    color(0.02), color(0.09), color(0.18), color(0.25), color(0.28), color(0.25), color(0.18), color(0.09), color(0.02),
                    color(0.02), color(0.10), color(0.20), color(0.28), color(0.32), color(0.28), color(0.20), color(0.10), color(0.02),
                    color(0.02), color(0.09), color(0.18), color(0.25), color(0.28), color(0.25), color(0.18), color(0.09), color(0.02),
                    color(0.02), color(0.06), color(0.12), color(0.18), color(0.20), color(0.18), color(0.12), color(0.06), color(0.02),
                    color(0.00), color(0.03), color(0.06), color(0.09), color(0.10), color(0.09), color(0.06), color(0.03), color(0.00),
                    color(0.00), color(0.00), color(0.02), color(0.02), color(0.02), color(0.02), color(0.02), color(0.00), color(0.00)
                ],
                smoothsColors: true,
                colorSpace: .device
            )
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.width)
    }
    
    private func color(_ opacity: Double) -> Color {
        color(fromHex: hexColor, opacity: opacity)
    }
    
    private func color(fromHex hex: String, opacity: Double = 1.0) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        guard hexSanitized.count == 6 else {
            return .clear // Return a default color if the hex string is invalid
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: r, green: g, blue: b).opacity(opacity)
    }
}

struct MeshGradientColorMixView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            MeshGradientColorMixView(hexColor: "7DE8D1")
                .background(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
