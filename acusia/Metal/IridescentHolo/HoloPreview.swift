//
//  HoloPreview.swift
//  acusia
//
//  Created by decoherence on 9/9/24.
//
import SwiftUI

struct HoloPreview: View {
    let startDate = Date()

    var body: some View {
        TimelineView(.animation) { context in
            Image(systemName: "star.fill")
                .font(.system(size: 200))
                .layerEffect(ShaderLibrary.iridescentEffect(
                    .float(startDate.timeIntervalSinceNow),
                    .texture(ShaderLibrary.perlinNoise),
                    .texture(ShaderLibrary.voronoiNoise)
                ), maxSampleOffset: .zero)
        }
    }
}

#Preview {
    HoloPreview()
}
