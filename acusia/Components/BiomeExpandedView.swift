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
            RoundedRectangle(cornerRadius: 45, style: .continuous)
                .fill(.ultraThickMaterial)
                .opacity(didAppear ? 0 : 1)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0 ..< biome.entities.count, id: \.self) { index in
                        let entity = biome.entities[index]
                        let isRoot = entity.parent == nil
                        let previousEntity = index > 0 ? biome.entities[index - 1] : nil
                        
                        EntityView(rootEntity: biome.entities[0], previousEntity: previousEntity, entity: entity, isRoot: isRoot, color: color, secondaryColor: secondaryColor)
                            .frame(maxHeight: .infinity)
                            .shadow(
                                color: isRoot ? .black.opacity(0.15) : .clear,
                                radius: isRoot ? 12 : 0,
                                x: 0,
                                y: isRoot ? 4 : 0
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, safeAreaInsets.bottom)
            }
            .defaultScrollAnchor(.bottom)
        }
        .overlay(alignment: .top) {
            Image(systemName: "chevron.down")
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(color)
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.7)) {
                didAppear = true
            }
        }
    }
}
