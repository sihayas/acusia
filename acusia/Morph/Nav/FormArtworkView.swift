//
//  FormArtworkView.swift
//  acusia
//
//  Created by decoherence on 7/13/24.
//

import SwiftUI

struct FormArtworkView: View {
    var soundData: APIAppleSoundData
    
    @State private var blurRadius: CGFloat = 32
    @State private var scale: CGFloat = 0.2  // Changed from 0.0 to avoid extreme scaling
    @State private var rotationAngle: Double = 20
    @State private var swivelAngle: Double = -15
    @State private var opacity: Double = 0.5
    @State private var isImageLoaded = false
    
    var body: some View {
        VStack {
            AsyncImage(url: artworkURL(width: 600, height: 600)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onAppear {
                            isImageLoaded = true
                        }
                case .empty, .failure:
                    Color.gray  // Placeholder color
                @unknown default:
                    Color.gray
                }
            }
            .frame(width: 232, height: 232)
            .cornerRadius(18)
            .shadow(radius: 16, x: 0, y: 8)
            .blur(radius: blurRadius)
            .scaleEffect(scale, anchor: .leading)
            .opacity(opacity)
        }
        .onChange(of: isImageLoaded) { _ in
            if isImageLoaded {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.2)) {
                    blurRadius = 0
                    rotationAngle = 0
                    swivelAngle = 0
                    scale = 1
                    opacity = 1
                }
            }
        }
    }
    
    private func artworkURL(width: Int, height: Int) -> URL? {
        let urlString = soundData.artworkUrl
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
        return URL(string: urlString)
    }
}
