//
//  BiomeDetailView.swift
//  acusia
//
//  Created by decoherence on 11/7/24.
//
import SwiftUI

struct BiomeExpandedView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State var didAppear = false

    let biome: Biome
    let color = Color(UIColor.systemGray6)
    let secondaryColor = Color(UIColor.systemGray5)

    var body: some View {
        ZStack {
            // RoundedRectangle(cornerRadius: 45, style: .continuous)
            //     .fill(.black)
            //     .opacity(didAppear ? 0 : 1)
            //     .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0 ..< biome.entities.count, id: \.self) { index in
                        let previousEntity = index > 0 ? biome.entities[index - 1] : nil

                        EntityView(
                            rootEntity: biome.entities[0],
                            previousEntity: previousEntity,
                            entity: biome.entities[index]
                        )
                        .frame(maxHeight: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, safeAreaInsets.bottom)
            }
            .defaultScrollAnchor(.bottom)
        }
        .overlay(alignment: .top) {
            VStack {
                VariableBlurView(radius: 1, mask: Image(.gradient))
                    .scaleEffect(x: 1, y: -1)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top * 1.5)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.7)) {
                didAppear = true
            }
        }
    }
}
