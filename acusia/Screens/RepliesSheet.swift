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

    struct Layer: Identifiable {
        let id = UUID()
        var state: LayerState = .expanded
        var offsetY: CGFloat = 0
        var selectedReply: Reply?
        var isHidden: Bool = false

        var isCollapsed: Bool {
            state.isCollapsed
        }

        var dynamicHeight: CGFloat? {
            state.maskHeight
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

        var maskHeight: CGFloat? {
            switch self {
            case .expanded:
                return nil
            case .collapsed(let height):
                return height
            }
        }
    }

    func pushLayer() {
        layers.append(Layer())
    }

    func popLayer(at index: Int) {
        if layers.indices.contains(index) {
            layers.remove(at: index)
        }
    }

    func updateOffsets(collapsedOffset: CGFloat) {
        var offset: CGFloat = 0

        for index in 1 ..< layers.count {
            if layers[index].isCollapsed {
                offset -= collapsedOffset
                layers[index].offsetY = offset
            }
        }
    }
}

struct RepliesSheet: View {
    @EnvironmentObject private var windowState: WindowState
    @StateObject private var layerManager = LayerManager()

    var size: CGSize
    var minHomeHeight: CGFloat

    var body: some View {
        let collapsedHeight = minHomeHeight * 2.25
        let collapsedOffset = minHomeHeight * 1.25
        ZStack(alignment: .bottom) {
            ForEach(Array(layerManager.layers.enumerated()), id: \.element.id) { index, layer in
                LayerView(
                    layerManager: layerManager,
                    width: size.width,
                    height: size.height,
                    collapsedHeight: collapsedHeight,
                    collapsedOffset: collapsedOffset,
                    layer: layer,
                    index: index
                )
                .zIndex(Double(layerManager.layers.count - index))
            }
        }
        .frame(width: size.width, height: size.height, alignment: .bottom) // Make sure it's always bottom aligned.
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
    @Namespace private var namespace

    let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow]
    let width: CGFloat
    let height: CGFloat
    let collapsedHeight: CGFloat
    let collapsedOffset: CGFloat
    let layer: LayerManager.Layer
    let index: Int
    // let cornerRadius = max(UIScreen.main.displayCornerRadius, 12)
    let cornerRadius: CGFloat = 45

    var body: some View {
        ZStack {
            LayerScrollViewWrapper(
                scrollState: $scrollState,
                scrollDisabled: $scrollDisabled,
                isOffsetAtTop: $isOffsetAtTop,
                blurRadius: $blurRadius,
                scale: $scale,
                width: width,
                height: height,
                index: index,
                collapsedHeight: collapsedHeight,
                collapsedOffset: collapsedOffset,
                layerManager: layerManager,
                layer: layer,
                namespace: namespace
            )

            VStack(alignment: .leading) { // Make sure it's always top leading aligned.
                VStack(alignment: .leading) { // Reserve space for match geometry to work.
                    if layer.selectedReply != nil {
                        ReplyView(reply: layer.selectedReply!)
                            .matchedGeometryEffect(id: layer.selectedReply!.id, in: namespace)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    layerManager.popLayer(at: index)
                                    layerManager.layers[index].selectedReply = nil
                                }
                            }
                            .transition(.scale(1.0))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .frame(width: width)
                .transition(.scale(1.0))

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(minWidth: width, minHeight: height)
        .frame(height: layer.state.maskHeight, alignment: .top)
        // .background(layer.isCollapsed ? colors[index % colors.count] : .clear)
        .background(.black.opacity(layer.isCollapsed ? 0 : 1.0))
        .background(
            BlurView(style: .dark, backgroundColor: .black, blurMutingFactor: 0.5)
                .edgesIgnoringSafeArea(.all)
        )
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: cornerRadius))
        .contentShape(UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: cornerRadius)) // Prevent touch inputs beyond.
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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

                            // Expand previous layer.
                            layerManager.layers[index - 1].state = .collapsed(height: newHeight)

                            // Animated through .animation.
                            blurRadius = min(max(dragY / 100, 0), 4)
                            scale = 1 - dragY / 1000
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
                           verticalDrag > height / 2 || verticalVelocity > velocityThreshold
                        {
                            // Expand the previous layer & animate the current.
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .expanded
                                layerManager.layers[index - 1].offsetY = 0 // Reset the previous view offset.
                                layerManager.layers[index - 1].selectedReply = nil
                                layerManager.layers[index - 1].isHidden = false
                            } completion: {
                                layerManager.popLayer(at: index)
                            }
                        } else {
                            // Reset
                            withAnimation(.spring()) {
                                layerManager.layers[index - 1].state = .collapsed(height: collapsedHeight)
                            }
                            blurRadius = 0
                            scale = 1
                        }
                    }
                }
        )
    }
}

struct LayerScrollViewWrapper: UIViewControllerRepresentable {
    @Binding var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @Binding var scrollDisabled: Bool
    @Binding var isOffsetAtTop: Bool
    @Binding var blurRadius: CGFloat
    @Binding var scale: CGFloat

    let width: CGFloat
    let height: CGFloat
    let index: Int
    let collapsedHeight: CGFloat
    let collapsedOffset: CGFloat
    let layerManager: LayerManager
    let layer: LayerManager.Layer
    let namespace: Namespace.ID

    func makeUIViewController(context: Context) -> UIHostingController<LayerScrollView> {
        let layerScrollView = LayerScrollView(
            scrollState: $scrollState,
            scrollDisabled: $scrollDisabled,
            isOffsetAtTop: $isOffsetAtTop,
            blurRadius: $blurRadius,
            scale: $scale,
            width: width,
            height: height,
            index: index,
            collapsedHeight: collapsedHeight,
            collapsedOffset: collapsedOffset,
            layerManager: layerManager,
            layer: layer,
            namespace: namespace
        )

        let hostingController = UIHostingController(rootView: layerScrollView)
        hostingController.view.backgroundColor = .clear
        hostingController.safeAreaRegions = []
        // hostingController.sizingOptions = .intrinsicContentSize
        return hostingController
    }

    func updateUIViewController(_ uiViewController: UIHostingController<LayerScrollView>, context: Context) {
        uiViewController.view.isHidden = layer.isHidden
    }

    typealias UIViewControllerType = UIHostingController<LayerScrollView>
}

struct LayerScrollView: View {
    @EnvironmentObject private var windowState: WindowState
    @Binding var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @Binding var scrollDisabled: Bool
    @Binding var isOffsetAtTop: Bool
    @Binding var blurRadius: CGFloat
    @Binding var scale: CGFloat

    let width: CGFloat
    let height: CGFloat
    let index: Int
    let collapsedHeight: CGFloat
    let collapsedOffset: CGFloat
    let layerManager: LayerManager
    let layer: LayerManager.Layer
    let namespace: Namespace.ID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(sampleComments) { reply in
                    if index < layerManager.layers.count {
                        ReplyView(reply: reply)
                            .opacity(layer.selectedReply == reply ? 0 : 1)
                            .matchedGeometryEffect(id: reply.id, in: namespace)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    layerManager.layers[index].state = .collapsed(height: collapsedHeight)
                                    layerManager.updateOffsets(collapsedOffset: collapsedOffset)
                                    layerManager.layers[index].selectedReply = reply
                                    layerManager.pushLayer()
                                } completion: {
                                    layerManager.layers[index].isHidden = true
                                    print("Selected reply \(layerManager.layers[index].selectedReply?.id ?? UUID())")
                                }
                            }
                            .onChange(of: layerManager.layers[index].selectedReply) { reply in
                                print("Selected reply")
                            }
                    }
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
