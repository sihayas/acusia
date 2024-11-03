//
//  Grok.swift
//  acusia
//
//  Created by decoherence on 10/31/24.
//
import SwiftUI

struct CircleGridView: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    let startDate = Date()

    var body: some View {
        TimelineView(.animation) { _ in
            VStack {
                HStack {
                    Text("Grok")
                        .font(.system(size: 34, weight: .semibold))
                    Spacer()
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 32) {
                        VStack {
                            ZStack {
                                Image("robot")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .scaleEffect(1.0)
                                    .mask(
                                        Circle()
                                            .padding(8)
                                            .background(.clear)
                                            .drawingGroup()
                                            .visualEffect { content, proxy in
                                                content
                                                    .distortionEffect(ShaderLibrary.complexWave(
                                                        .float(startDate.timeIntervalSinceNow),
                                                        .float2(proxy.size),
                                                        .float(0.1),
                                                        .float(6),
                                                        .float(10)
                                                    ), maxSampleOffset: .zero)
                                            }
                                    )
                                    .overlay(
                                        RadialVariableBlurView(radius: 4, size: CGSize(width: 350, height: 350))
                                        
                                    )
                                    .overlay(alignment: .topTrailing) {
                                        Text("2 pills im a ROVER.. get it? because you like bladee? 😔 anyways here's...")
                                            .foregroundColor(.secondary)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(.regularMaterial        .shadow(.inner(color: .white.opacity(0.1), radius: 4, x: 1, y: 1)), in: BubbleWithTailShape(scale: 1))
                                            .lineLimit(3)
                                            .alignmentGuide(VerticalAlignment.top) { d in d.height / 4 }
                                            .alignmentGuide(HorizontalAlignment.trailing) { d in d.width / 1.75 }
                                    }
                            }
                            VStack(spacing: 4) {
                                Text("Image Fun")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text("2 Days Ago")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    
                            }
                        }
                    }
                }
                .scrollClipDisabled(true)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct CircleGridView_Previews: PreviewProvider {
    static var previews: some View {
        CircleGridView()
    }
}
