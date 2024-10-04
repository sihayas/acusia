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
        var isVisible: Bool = true

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
        let collapsedOffset = size.height * 0.04

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
    @State private var dimmingOpacity: CGFloat = 0

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
            LayerScrollViewWrapper(
                scrollState: $scrollState,
                scrollDisabled: $scrollDisabled,
                isOffsetAtTop: $isOffsetAtTop,
                blurRadius: $blurRadius,
                scale: $scale,
                dimmingOpacity: $dimmingOpacity,
                sampleComments: sampleComments,
                width: width,
                height: height,
                index: index,
                collapsedHeight: collapsedHeight,
                collapsedOffset: collapsedOffset,
                layerManager: layerManager,
                layer: layer
            )

            Button {
                withAnimation(.spring()) {
                    layerManager.pushLayer()
                    layerManager.layers[index].state = .collapsed(height: collapsedHeight)
                    layerManager.updateOffsets(collapsedOffset: collapsedOffset)
                } completion: {
                    layerManager.layers[index].isVisible = false
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(minWidth: width, minHeight: height)
        .frame(height: layer.state.dynamicHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(layer.isCollapsed ? colors[index % colors.count] : .black)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .offset(y: layer.offsetY)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    guard index > 0 else { return }
                    let dragY = value.translation.height

                    // Slowly expands the previous layer if the user drags down.
                    if isOffsetAtTop, dragY > 0 {
                        if !scrollDisabled {
                            scrollDisabled = true
                        }
                        
                        if case .collapsed = layerManager.layers[index - 1].state {
                            let newHeight = collapsedHeight + dragY / 2

                            // Expand
                            layerManager.layers[index - 1].state = .collapsed(height: newHeight)

                            // Animated through .animation.
                            blurRadius = min(max(dragY / 100, 0), 4)
                            scale = 1 - dragY / 1000

                            dimmingOpacity = min(dragY / 1000, 0.3)
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
                            // On a successful drag down, expand the previous layer & animate the current.
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .expanded
                                layerManager.layers[index - 1].offsetY = 0 // Reset the previous view offset.
                                layerManager.layers[index - 1].isVisible = true
                            } completion: {
                                layerManager.popLayer(at: index)
                            }
                        } else {
                            // Reset
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .collapsed(height: collapsedHeight)
                                dimmingOpacity = 0
                            }
                            blurRadius = 0
                            scale = 1
                        }
                    }
                }
        )
    }
}

struct LayerScrollView: View {
    @EnvironmentObject private var windowState: WindowState
    @Binding var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @Binding var scrollDisabled: Bool
    @Binding var isOffsetAtTop: Bool
    @Binding var blurRadius: CGFloat
    @Binding var scale: CGFloat
    @Binding var dimmingOpacity: CGFloat

    let sampleComments: [Reply]
    let width: CGFloat
    let height: CGFloat
    let index: Int
    let collapsedHeight: CGFloat
    let collapsedOffset: CGFloat
    let layerManager: LayerManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(sampleComments) { reply in
                    ReplyView(reply: reply)
                }
            }
            .padding(24)
            .padding(.top, 64)
            .scaleEffect(scale)
            .animation(.spring(), value: scale)
        }
        .frame(minWidth: width, minHeight: height)
        .blur(radius: blurRadius)
        .animation(.spring(), value: blurRadius)
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
    }
}

struct LayerScrollViewWrapper: UIViewControllerRepresentable {
    @Binding var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @Binding var scrollDisabled: Bool
    @Binding var isOffsetAtTop: Bool
    @Binding var blurRadius: CGFloat
    @Binding var scale: CGFloat
    @Binding var dimmingOpacity: CGFloat
    
    let sampleComments: [Reply]
    let width: CGFloat
    let height: CGFloat
    let index: Int
    let collapsedHeight: CGFloat
    let collapsedOffset: CGFloat
    let layerManager: LayerManager
    let layer: LayerManager.Layer // Add the layer to access its `isVisible` property

    func makeUIViewController(context: Context) -> UIHostingController<LayerScrollView> {
        let layerScrollView = LayerScrollView(
            scrollState: $scrollState,
            scrollDisabled: $scrollDisabled,
            isOffsetAtTop: $isOffsetAtTop,
            blurRadius: $blurRadius,
            scale: $scale,
            dimmingOpacity: $dimmingOpacity,
            sampleComments: sampleComments,
            width: width,
            height: height,
            index: index,
            collapsedHeight: collapsedHeight,
            collapsedOffset: collapsedOffset,
            layerManager: layerManager
        )

        let hostingController = UIHostingController(rootView: layerScrollView)
        hostingController.view.backgroundColor = .clear
        hostingController.safeAreaRegions = []
//        hostingController.sizingOptions = .intrinsicContentSize
        return hostingController
    }

    func updateUIViewController(_ uiViewController: UIHostingController<LayerScrollView>, context: Context) {
        // Update visibility based on layer.isVisible property
        uiViewController.view.isHidden = !layer.isVisible
    }

    typealias UIViewControllerType = UIHostingController<LayerScrollView>
}
