//
//  ReplySheet.swift
//  acusia
//
//  Created by decoherence on 9/8/24.
//
import SwiftUI
import Transmission

class LayerManager: ObservableObject {
    @Published var layers: [Layer] = [Layer()]

    func pushLayer() {
        layers.append(Layer())
    }

    func popLayer(at index: Int) {
        if layers.indices.contains(index) {
            layers.remove(at: index)
        }
    }

    func updateOffsets(collapsedOffset: CGFloat) {
        var totalOffset: CGFloat = 0

        for index in 0 ..< layers.count {
            if layers[index].isCollapsed {
                totalOffset -= collapsedOffset
                layers[index].offsetY = totalOffset
            }
        }
    }

    struct Layer: Identifiable {
        let id = UUID()
        var state: LayerState = .expanded
        var offsetY: CGFloat = 0

        var isCollapsed: Bool {
            state.isCollapsed
        }

        var dynamicHeight: CGFloat? {
            state.dynamicHeight
        }
    }

    enum LayerState {
        case expanded
        case collapsed(height: CGFloat)

        var isCollapsed: Bool {
            if case .collapsed = self {
                return true
            }
            return false
        }

        var dynamicHeight: CGFloat? {
            switch self {
            case .expanded:
                return nil
            case .collapsed(let height):
                return height
            }
        }
    }
}

struct RepliesSheet: View {
    @EnvironmentObject private var windowState: WindowState
    @StateObject private var layerManager = LayerManager()

    var size: CGSize

    var body: some View {
        let heightCenter = size.height / 2
        let collapsedHeight = size.height * 0.21
        let collapsedOffset = size.height * 0.07

        ZStack(alignment: .bottom) {
            ForEach(Array(layerManager.layers.enumerated()), id: \.element.id) { index, layer in
                LayerView(
                    layerManager: layerManager,
                    sampleComments: sampleComments,
                    width: size.width,
                    height: size.height,
                    heightCenter: heightCenter,
                    collapsedHeight: collapsedHeight,
                    collapsedOffset: collapsedOffset,
                    layer: layer,
                    index: index
                )
                .zIndex(Double(layerManager.layers.count - index))
            }
        }
        .onReceive(layerManager.$layers) { layers in
            windowState.isLayered = layers.count > 1
        }
    }
}

struct LayerView: View {
    @EnvironmentObject private var windowState: WindowState
    @ObservedObject var layerManager: LayerManager

    @State private var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @State private var scrollDisabled = false
    @State private var isOffsetAtTop = true
    @State private var blurRadius: CGFloat = 0
    @State private var scale: CGFloat = 1

    let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow]
    let sampleComments: [Reply]
    let width: CGFloat
    let height: CGFloat
    let heightCenter: CGFloat
    let collapsedHeight: CGFloat
    let collapsedOffset: CGFloat
    let layer: LayerManager.Layer
    let index: Int
    let cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sampleComments) { reply in
                        ReplyView(reply: reply)
                    }
                }
                .padding(.horizontal, 24)
                .scaleEffect(scale)
            }
            .blur(radius: blurRadius)
            .scrollDisabled(scrollDisabled)
            .onScrollPhaseChange { _, newPhase, context in
                scrollState = (newPhase, context)
            }
            .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y
            }, action: { _, newValue in
                if newValue <= 0 {
                    index == 0 ? (windowState.isOffsetAtTop = true) : (isOffsetAtTop = true)
                } else if newValue > 0 {
                    index == 0 ? (windowState.isOffsetAtTop = false) : (isOffsetAtTop = false)
                }
            })
            
            Button() {
                layerManager.pushLayer()
                layerManager.layers[index].state = .collapsed(height: collapsedHeight)
                layerManager.updateOffsets(collapsedOffset: collapsedOffset)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .frame(minWidth: width, minHeight: height)
        .frame(height: layer.state.dynamicHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(layer.isCollapsed ? colors[index % colors.count] : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .offset(y: layer.offsetY)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    guard index > 0 else { return }
                    let dragY = value.translation.height

                    // Slowly expands the previous layer if there is one if the user drags down.
                    if isOffsetAtTop, dragY > 0 {
                        if !scrollDisabled {
                            scrollDisabled = true
                        }
                        if case .collapsed = layerManager.layers[index - 1].state {
                            let newHeight = collapsedHeight + dragY / 2

                            layerManager.layers[index - 1].state = .collapsed(height: newHeight)

                            withAnimation(.spring()) {
                                blurRadius = min(max(dragY / 100, 0), 4)
                                scale = 1 - dragY / 1000
                            }
                        }
                    }
                }
                .onEnded { value in
                    guard index > 0 else { return }
                    let verticalDrag = value.translation.height
                    let verticalVelocity = value.velocity.height
                    let velocityThreshold: CGFloat = 500
                    scrollDisabled = false

                    if isOffsetAtTop, verticalDrag > 0 {
                        if case .collapsed = layerManager.layers[index - 1].state,
                           verticalDrag > heightCenter || verticalVelocity > velocityThreshold
                        {
                            // On a successful drag down, collapse the previous layer & animate the current.
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .expanded
                                layerManager.layers[index - 1].offsetY = 0 // Reset the previous view offset.
                                layerManager.layers[index].offsetY = height // Slide the current view down.
                            } completion: {
                                layerManager.popLayer(at: index)
                            }
                        } else {
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .collapsed(height: collapsedHeight)
                                blurRadius = 0
                                scale = 1
                            }
                        }
                    }
                }
        )
        .animation(.spring(), value: layer.isCollapsed)
    }
}
