//
//  ReplySheet.swift
//  acusia
//
//  Created by decoherence on 9/8/24.
//
import SwiftUI
import Transmission

class LayerManager: ObservableObject {
    @Published var layers: [Layer] = [Layer(maskHeight: 0)]
    @Published var viewSize: CGSize = .zero

    struct Layer: Identifiable {
        let id = UUID()
        // Match geometry
        var selectedReply: Reply?

        // Controls reply collapse & hiding hosting content
        var isHidden: Bool = false
        var isCollapsed: Bool = false

        // Store the calculated height
        var collapsedHeight: CGFloat = 0
        var maskHeight: CGFloat
    }

    func pushLayer() {
        layers.append(Layer(maskHeight: viewSize.height))
    }

    func popLayer(at index: Int) {
        guard layers.indices.contains(index) else { return }
        layers.remove(at: index)
    }

    func previousLayer(before index: Int) -> Layer? {
        let previousIndex = index - 1
        guard layers.indices.contains(previousIndex) else { return nil }
        return layers[previousIndex]
    }
}

struct RepliesSheet: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: WindowState
    @StateObject private var layerManager = LayerManager()

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(layerManager.layers.enumerated()), id: \.element.id) { index, layer in
                LayerView(
                    layerManager: layerManager,
                    layer: layer,
                    index: index
                )
                .zIndex(Double(layerManager.layers.count - index))
            }

            if layerManager.layers.count > 1 {
                Rectangle()
                    .background(
                        VariableBlurView(radius: 4, mask: Image(.gradient))
                            .scaleEffect(y: -1)
                    )
                    .foregroundColor(.clear)
                    .frame(
                        width: windowState.size.width,
                        height:  windowState.collapsedHomeHeight + (safeAreaInsets.top * CGFloat(layerManager.layers.count))
                    )
                    .animation(.spring(), value: layerManager.layers.count)
                    .zIndex(1.5)
            }
        }
        .frame(width: windowState.size.width, height: windowState.size.height, alignment: .top) // Important to align collapsed layers.
        .onReceive(layerManager.$layers) { layers in
            windowState.isLayered = layers.count > 1
        }
        .onAppear {
            layerManager.viewSize = windowState.size
            layerManager.layers[0].maskHeight = windowState.size.height // Set initial mask height
        }
    }
}

// MARK: LayerView

struct LayerView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: WindowState
    @ObservedObject var layerManager: LayerManager

    @State private var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @State private var scrollDisabled = false
    @State private var scrollOffsetAtTop = true
    @State private var blurRadius: CGFloat = 0
    @State private var scale: CGFloat = 1
    @Namespace private var namespace

    let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow]
    let layer: LayerManager.Layer
    let index: Int
    let cornerRadius: CGFloat = 20

    var body: some View {
        ZStack {
            LayerScrollViewWrapper(
                scrollState: $scrollState,
                scrollDisabled: $scrollDisabled,
                isOffsetAtTop: $scrollOffsetAtTop,
                index: index,
                layerManager: layerManager,
                layer: layer,
                namespace: namespace
            )
            .blur(radius: blurRadius)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(minWidth: windowState.size.width, minHeight: windowState.size.height)
        .frame(height: layer.maskHeight, alignment: .top)
        .overlay(alignment: .bottom) {
            // Make sure it's always top leading aligned.
            VStack(alignment: .leading) {
                // Reserve space for match geometry to work.
                VStack(alignment: .leading) {
                    if layer.selectedReply != nil {
                        ReplyView(reply: layer.selectedReply!, isCollapsed: layer.isHidden)
                            .matchedGeometryEffect(id: layer.selectedReply!.id, in: namespace)
                            .transition(.scale(1.0))
                    }
                }
                .padding(.bottom, 12)
                .padding(.horizontal, 24)
                .frame(
                    width: windowState.size.width,
                    height: layer.collapsedHeight, alignment: .bottom
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
        }
        // .background(layer.isCollapsed ? colors[index % colors.count] : .clear)
        .background(.black.opacity(layer.isHidden ? 0 : 1.0))
        .animation(.spring(), value: layer.isHidden)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, topTrailingRadius: 0))
        .contentShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, topTrailingRadius: 0)) // Prevent touch inputs beyond.
        .overlay(
            BottomLeftRightArcPath(cornerRadius: cornerRadius)
                .strokeBorder(
                    Color(UIColor.systemGray6),
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .padding(.horizontal, 12)
        )
        .simultaneousGesture( // MARK: Layer Drag Gestures
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    let verticalDrag = value.translation.height

                    guard verticalDrag > 0 else { return }

                    let currentLayer = layer

                    // Begin to pop, animate the current layer, push the previous.
                    if scrollOffsetAtTop, !currentLayer.isCollapsed {
                        // Can't push a previous layer if it's the first layer.
                        guard index > 0 else { return }

                        if !scrollDisabled { scrollDisabled = true }

                        let previousIndex = index - 1
                        let previousLayer = layerManager.layers[previousIndex]

                        let previousHeight = previousLayer.maskHeight
                        let newHeight = previousHeight + verticalDrag / 20

                        if previousLayer.isCollapsed {
                            // Push previous layer.
                            layerManager.layers[previousIndex].maskHeight = newHeight

                            // Pop the current, animated through .animation.
                            blurRadius = min(max(verticalDrag / 100, 0), 4)
                            scale = 1 - verticalDrag / 1000
                        }
                    }

                    // Begin to push, animate the current layer.
                    if currentLayer.isCollapsed {
                        let currentHeight = currentLayer.maskHeight
                        let newHeight = currentHeight + verticalDrag / 20

                        layerManager.layers[index].maskHeight = newHeight

                        if verticalDrag > 80 {
                            layerManager.layers[index].isHidden = false
                        }
                    }
                }
                .onEnded { value in
                    let verticalDrag = value.translation.height
                    let verticalVelocity = value.velocity.height
                    let velocityThreshold: CGFloat = 500
                    let shouldExpand = verticalDrag > windowState.size.height / 2 || verticalVelocity > velocityThreshold

                    scrollDisabled = false

                    guard verticalDrag > 0 else { return }

                    let currentLayer = layer

                    // Pop the current layer, push the previous.
                    if scrollOffsetAtTop, !currentLayer.isCollapsed {
                        guard index > 0 else { return }

                        let previousIndex = index - 1
                        let previousLayer = layerManager.layers[previousIndex]

                        if previousLayer.isCollapsed {
                            if shouldExpand {
                                // Expand the previous layer & scale away the current.
                                layerManager.layers[previousIndex].isHidden = false

                                withAnimation(.spring()) {
                                    layerManager.popLayer(at: index) // Pop the current layer.
                                    layerManager.layers[previousIndex].isCollapsed = false
                                    layerManager.layers[previousIndex].selectedReply = nil
                                    layerManager.layers[previousIndex].maskHeight = windowState.size.height
                                }
                            } else {
                                // Cancel the push.
                                withAnimation(.spring()) {
                                    layerManager.layers[previousIndex].isHidden = true
                                    layerManager.layers[previousIndex].maskHeight = previousLayer.collapsedHeight
                                }

                                blurRadius = 0
                                scale = 1
                            }
                        }
                    }

                    // Push the current layer, pop all layers after.
                    if currentLayer.isCollapsed {
                        if shouldExpand {
                            // Expand the layer.
                            withAnimation(.spring()) {
                                // Pop all layers after the current one.
                                for i in stride(from: layerManager.layers.count - 1, through: index + 1, by: -1) {
                                    layerManager.popLayer(at: i)
                                }
                                layerManager.layers[index].isCollapsed = false
                                layerManager.layers[index].selectedReply = nil
                                layerManager.layers[index].maskHeight = windowState.size.height
                            } completion: {}
                        } else {
                            // Cancel the expansion.
                            withAnimation(.spring()) {
                                layerManager.layers[index].isHidden = true
                                layerManager.layers[index].maskHeight = currentLayer.collapsedHeight
                            }
                        }
                    }
                }
        )
    }
}

// MARK: LayerScrollViewWrapper

struct LayerScrollViewWrapper: UIViewControllerRepresentable {
    @Binding var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @Binding var scrollDisabled: Bool
    @Binding var isOffsetAtTop: Bool

    let index: Int
    let layerManager: LayerManager
    let layer: LayerManager.Layer
    let namespace: Namespace.ID

    func makeUIViewController(context: Context) -> UIHostingController<LayerScrollView> {
        let layerScrollView = LayerScrollView(
            scrollState: $scrollState,
            scrollDisabled: $scrollDisabled,
            isOffsetAtTop: $isOffsetAtTop,
            index: index,
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
        // Use the UIView extension to animate hidden state
        uiViewController.view.animateSetHidden(layer.isCollapsed,
                                               duration: 0.3)
    }

    typealias UIViewControllerType = UIHostingController<LayerScrollView>
}

// MARK: LayerScrollView

struct LayerScrollView: View {
    @EnvironmentObject private var windowState: WindowState
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Binding var scrollState: (phase: ScrollPhase, context: ScrollPhaseChangeContext)?
    @Binding var scrollDisabled: Bool
    @Binding var isOffsetAtTop: Bool

    let index: Int
    let layerManager: LayerManager
    let layer: LayerManager.Layer
    let namespace: Namespace.ID

    private var baseHeight: CGFloat {
        windowState.collapsedHomeHeight + (safeAreaInsets.top * CGFloat(index + 1))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(sampleComments) { reply in
                    ZStack {
                        // Ghost to occupy space.
                        ReplyView(reply: reply, isCollapsed: false)
                            .hidden()

                        if layer.selectedReply?.id != reply.id {
                            ReplyView(reply: reply, isCollapsed: false)
                                .matchedGeometryEffect(id: reply.id, in: namespace)
                                .animation(nil, value: layer.selectedReply?.id)
                                .onTapGesture {
                                    withAnimation(.smooth) {
                                        layerManager.layers[index].selectedReply = reply
                                    }
                                    withAnimation(.spring()) {
                                        layerManager.layers[index].isCollapsed = true
                                        layerManager.layers[index].collapsedHeight = baseHeight
                                        layerManager.layers[index].maskHeight = baseHeight
                                        layerManager.pushLayer()
                                    } completion: {
                                        layerManager.layers[index].isHidden = true
                                    }
                                }
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom], 24)
            .padding(.top, baseHeight)
        }
        .frame(minWidth: windowState.size.width, minHeight: windowState.size.height)
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

struct BottomLeftRightArcPath: InsettableShape {
    var cornerRadius: CGFloat
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Adjust the rect and corner radius based on the inset amount
        let adjustedRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let adjustedCornerRadius = cornerRadius - insetAmount

        // Bottom-left corner arc
        path.move(to: CGPoint(x: adjustedRect.minX, y: adjustedRect.maxY - adjustedCornerRadius))
        path.addArc(
            center: CGPoint(x: adjustedRect.minX + adjustedCornerRadius, y: adjustedRect.maxY - adjustedCornerRadius),
            radius: adjustedCornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 90),
            clockwise: true
        )

        // Bottom-right corner arc
        path.move(to: CGPoint(x: adjustedRect.maxX - adjustedCornerRadius, y: adjustedRect.maxY))
        path.addArc(
            center: CGPoint(x: adjustedRect.maxX - adjustedCornerRadius, y: adjustedRect.maxY - adjustedCornerRadius),
            radius: adjustedCornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 0),
            clockwise: true
        )

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var newShape = self
        newShape.insetAmount += amount
        return newShape
    }
}
