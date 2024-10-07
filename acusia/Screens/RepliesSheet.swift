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

        var isExpanded: Bool {
            state.isExpanded
        }

        var dynamicHeight: CGFloat? {
            state.maskHeight
        }
    }

    enum LayerState {
        case expanded
        case collapsed(height: CGFloat)

        var isCollapsed: Bool {
            if case .collapsed = self { return true }
            return false
        }

        var isExpanded: Bool {
            if case .expanded = self { return true }
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
        guard layers.indices.contains(index) else { return }
        layers.remove(at: index)
    }

    func updateOffsets(collapsedOffset: CGFloat) {
        var offset: CGFloat = 0

        for index in 1 ..< layers.count {
            if layers[index].isCollapsed {
                offset += collapsedOffset
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
        let collapsedHeight = minHomeHeight * 4
        let collapsedOffset = minHomeHeight * 2

        ZStack(alignment: .top) {
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

            if layerManager.layers.count > 1 {
                Rectangle()
                    .background(
                        VariableBlurView(radius: 6, mask: Image(.gradient))
                            .scaleEffect(y: -1)
                    )
                    .foregroundColor(.clear)
                    .frame(width: size.width, height: collapsedOffset * CGFloat(layerManager.layers.count))
                    .zIndex(1.5)
            }
        }
        .frame(width: size.width, height: size.height, alignment: .top) // Important to align collapsed layers.
        .onReceive(layerManager.$layers) { layers in
            windowState.isLayered = layers.count > 1
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
    let cornerRadius: CGFloat = 20

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
                        ReplyView(reply: layer.selectedReply!, isCollapsed: layer.isHidden)
                            .matchedGeometryEffect(id: layer.selectedReply!.id, in: namespace)
                            .transition(.scale(1.0))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, safeAreaInsets.top)
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
        .background(.black.opacity(layer.isHidden ? 0 : 1.0))
        .animation(.spring(), value: layer.isHidden)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, topTrailingRadius: 0))
        .contentShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, topTrailingRadius: 0)) // Prevent touch inputs beyond.
        .overlay(
            BottomLeftRightArcPath(cornerRadius: cornerRadius)
                .strokeBorder(
                    Color(UIColor.systemGray6),
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
        )
        .offset(y: layer.offsetY)
        .simultaneousGesture( // MARK: Layer Drag Gestures
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    let verticalDrag = value.translation.height
                    guard verticalDrag > 0 else { return }

                    let newHeight = collapsedHeight + verticalDrag / 2
                    let currentLayer = layerManager.layers[index]

                    // Dragging down on an expanded layer & offset is at the top,
                    // Disable scrolling, expand the previous layer, animate away the current layer
                    if isOffsetAtTop, currentLayer.isExpanded {
                        guard index > 0 else { return }
                        if !scrollDisabled { scrollDisabled = true }

                        let previousIndex = index - 1
                        let previousLayer = layerManager.layers[previousIndex]

                        if previousLayer.isCollapsed {
                            // Expand previous layer.
                            layerManager.layers[previousIndex].state = .collapsed(height: newHeight)

                            // Obscure the current, animated through .animation.
                            blurRadius = min(max(verticalDrag / 100, 0), 4)
                            scale = 1 - verticalDrag / 1000

                            if verticalDrag > 100 {
                                // Prepare the previous layer, render the content.
                                layerManager.layers[previousIndex].isHidden = false
                            }
                        }
                    }

                    // If the user drags down on a collapsed layer, expand the layer
                    if currentLayer.isCollapsed {
                        layerManager.layers[index].state = .collapsed(height: newHeight)

                        if verticalDrag > 80 {
                            // Prepare the layer, render the content.
                            layerManager.layers[index].isHidden = false
                        }
                    }
                }
                .onEnded { value in
                    let verticalDrag = value.translation.height
                    let verticalVelocity = value.velocity.height
                    let velocityThreshold: CGFloat = 500
                    let shouldExpand = verticalDrag > height / 2 || verticalVelocity > velocityThreshold

                    scrollDisabled = false
                    guard verticalDrag > 0 else { return }

                    let currentLayer = layerManager.layers[index]

                    // Pop current
                    if isOffsetAtTop, currentLayer.isExpanded {
                        guard index > 0 else { return }
                        let previousIndex = index - 1
                        let previousLayer = layerManager.layers[previousIndex]

                        if previousLayer.isCollapsed {
                            if shouldExpand {
                                // Expand the previous layer & scale away the current.
                                withAnimation(.spring()) {
                                    layerManager.layers[previousIndex].state = .expanded
                                    layerManager.layers[previousIndex].offsetY = 0 // Reset the previous view offset.
                                } completion: {
                                    // Pop the current layer.
                                    layerManager.layers[previousIndex].selectedReply = nil
                                    layerManager.popLayer(at: index)
                                }
                            } else {
                                // Cancel the expansion.
                                blurRadius = 0
                                scale = 1
                                
                                withAnimation(.spring()) {
                                    layerManager.layers[previousIndex].isHidden = true
                                    layerManager.layers[previousIndex].state = .collapsed(height: collapsedHeight)
                                }
                            }
                        }
                    }

                    // Pop all after current
                    if currentLayer.isCollapsed {
                        if shouldExpand {
                            // Expand the layer.
                            withAnimation(.spring()) {
                                layerManager.layers[index].state = .expanded
                                layerManager.layers[index].offsetY = 0 // Reset the view offset.
                                layerManager.layers[index].selectedReply = nil
                            } completion: {
                                // Pop all layers after the current one.
                                for i in stride(from: layerManager.layers.count - 1, through: index + 1, by: -1) {
                                    layerManager.popLayer(at: i)
                                }
                            }
                        } else {
                            // Cancel the expansion.
                            withAnimation(.spring()) {
                                layerManager.layers[index].isHidden = true
                                layerManager.layers[index].state = .collapsed(height: collapsedHeight)
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
        return hostingController
    }

    func updateUIViewController(_ uiViewController: UIHostingController<LayerScrollView>, context: Context) {
        // Use the UIView extension to animate hidden state
        uiViewController.view.animateSetHidden(layer.isCollapsed
                                               , duration: 0.3)
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
                    ZStack {
                        ReplyView(reply: reply, isCollapsed: false)
                            .matchedGeometryEffect(id: reply.id, in: namespace)
                            .opacity(layer.selectedReply?.id == reply.id ? 0 : 1)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    layerManager.layers[index].state = .collapsed(height: collapsedHeight)
                                    layerManager.updateOffsets(collapsedOffset: collapsedOffset)
                                    layerManager.layers[index].selectedReply = reply
                                    layerManager.pushLayer()
                                } completion: {
                                    // Unrender content after animating away the other replies for effect.
                                    layerManager.layers[index].isHidden = true
                                }
                            }
                    }
                }
            }
            .padding(24)
            .padding(.top, index == 0 ? safeAreaInsets.top : safeAreaInsets.top + (collapsedOffset * CGFloat(index)))
            .scaleEffect(scale)
            .animation(.spring(), value: scale)
        }
        .frame(minWidth: width, minHeight: height)
        .blur(radius: blurRadius) // Blur and scale are separate because scale breaks drag gesture.
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

//
// struct PartialStrokeRoundedRectangle: Shape {
//     var cornerRadius: CGFloat
//
//     func path(in rect: CGRect) -> Path {
//         var path = Path()
//
//         // Bottom-left corner arc
//         path.move(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius))
//         path.addArc(
//             center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
//             radius: cornerRadius,
//             startAngle: Angle(degrees: 180),
//             endAngle: Angle(degrees: 90),
//             clockwise: true
//         )
//
//         // Move to the start point of the bottom-right corner arc
//         path.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
//         path.addArc(
//             center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
//             radius: cornerRadius,
//             startAngle: Angle(degrees: 90),
//             endAngle: Angle(degrees: 0),
//             clockwise: true
//         )
//
//         return path
//     }
// }
