//
//  CustomCardDeckPageView.swift
//  acusia
//
//  Created by decoherence on 8/15/24.
//
// This is a fork of the CardDeckPageView in the BigUIPaging package.
// The original code had a default scaleEffect applied to it. This
// remedies that.

import SwiftUI
import BigUIPaging

@available(macOS, unavailable)
@available(iOS 16.0, *)
public struct CustomCardDeckPageViewStyle: PageViewStyle {
    
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        CustomCardDeckPageView(configuration)
    }
}

struct CustomCardDeckPageView: View {
    
    typealias Value = PageViewStyleConfiguration.Value
    typealias Configuration = PageViewStyleConfiguration
    
    struct Page: Identifiable {
        let index: Int
        let value: Value
        
        var id: Value {
            return value
        }
    }
    
    let configuration: Configuration
    
    @State private var dragProgress = 0.0
    @State private var selectedIndex = 0
    @State private var pages = [Page]()
    @State private var containerSize = CGSize.zero
    
    @Environment(\.cardCornerRadius) private var cornerRadius
    @Environment(\.cardShadowDisabled) private var shadowDisabled

    init(_ configuration: Configuration) {
        self.configuration = configuration
    }
    
    var body: some View {
        ZStack {
            ForEach(pages) { page in
                configuration.content(page.value)
                    .cardStyle(cornerRadius: cornerRadius)
                    .zIndex(zIndex(for: page.index))
                    .offset(x: xOffset(for: page.index))
                    .scaleEffect(scale(for: page.index)) // Keep the scale effect for individual cards
                    .rotationEffect(.degrees(rotation(for: page.index)))
                    .shadow(color: shadow(for: page.index), radius: 30, y: 20)
            }
        }
        .measure($containerSize)
        .highPriorityGesture(dragGesture)
        .task {
            makePages(from: configuration.selection.wrappedValue)
        }
        .onChange(of: selectedIndex) { oldValue, newValue in
            configuration.selection.wrappedValue = pages[newValue].value
        }
        .onChange(of: configuration.selection.wrappedValue) { oldValue, newValue in
            makePages(from: newValue)
            self.dragProgress = 0.0
        }
    }
    
    func makePages(from value: Value) {
        let (values, index) = configuration.values(surrounding: value)
        self.pages = values.enumerated().map {
            Page(index: $0.offset, value: $0.element)
        }
        self.selectedIndex = index
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                self.dragProgress = -(value.translation.width / containerSize.width)
            }
            .onEnded { value in
                snapToNearestIndex()
            }
    }
    
    func snapToNearestIndex() {
        let threshold = 0.3
        if abs(dragProgress) < threshold {
            withAnimation(.bouncy) {
                self.dragProgress = 0.0
            }
        } else {
            let direction = dragProgress < 0 ? -1 : 1
            withAnimation(.smooth(duration: 0.25)) {
                go(to: selectedIndex + direction)
                self.dragProgress = 0.0
            }
        }
    }
    
    func go(to index: Int) {
        let maxIndex = pages.count - 1
        if index > maxIndex {
            self.selectedIndex = maxIndex
        } else if index < 0 {
            self.selectedIndex = 0
        } else {
            self.selectedIndex = index
        }
        self.dragProgress = 0
    }
    
    func currentPosition(for index: Int) -> Double {
        progressIndex - Double(index)
    }
    
    // MARK: - Geometry
    
    var progressIndex: Double {
        dragProgress + Double(selectedIndex)
    }
    
    func zIndex(for index: Int) -> Double {
        let position = currentPosition(for: index)
        return -abs(position)
    }
    
    func xOffset(for index: Int) -> Double {
        let padding = containerSize.width / 10
        let x = (Double(index) - progressIndex) * padding
        let maxIndex = pages.count - 1
        if index == selectedIndex && progressIndex < Double(maxIndex) && progressIndex > 0 {
            return x * swingOutMultiplier
        }
        return x
    }
    
    var swingOutMultiplier: Double {
        return abs(sin(Double.pi * progressIndex) * 20)
    }
    
    func scale(for index: Int) -> CGFloat {
        return 1.0 - (0.1 * abs(currentPosition(for: index)))
    }
    
    func rotation(for index: Int) -> Double {
        return -currentPosition(for: index) * 2
    }
    
    func shadow(for index: Int) -> Color {
        guard shadowDisabled == false else {
            return .clear
        }
        let index = Double(index)
        let progress = 1.0 - abs(progressIndex - index)
        let opacity = 0.3 * progress
        return .black.opacity(opacity)
    }
}

// MARK: - Styling options

extension EnvironmentValues {
    
    struct CardCornerRadius: EnvironmentKey {
        static var defaultValue: Double? = nil
    }
    
    var cardCornerRadius: Double? {
        get { self[CardCornerRadius.self] }
        set { self[CardCornerRadius.self] = newValue }
    }
    
    struct CardShadowDisabled: EnvironmentKey {
        static var defaultValue: Bool = false
    }
    
    var cardShadowDisabled: Bool {
        get { self[CardShadowDisabled.self] }
        set { self[CardShadowDisabled.self] = newValue }
    }
}

extension View {
    @ViewBuilder
    func cardStyle(cornerRadius: Double? = nil) -> some View {
        mask(
            RoundedRectangle(
                cornerRadius: cornerRadius ?? 45.0,
                style: .continuous
            )
        )
    }
}

@available(macOS, unavailable)
extension PageViewStyle where Self == CustomCardDeckPageViewStyle {
    
    public static var customCardDeck: CustomCardDeckPageViewStyle {
        CustomCardDeckPageViewStyle()
    }
}

extension View {
    
    /// Measures the geometry of the attached view.
    func measure(_ size: Binding<CGSize>) -> some View {
        self.background {
            GeometryReader { reader in
                Color.clear.preference(
                    key: ViewSizePreferenceKey.self,
                    value: reader.size
                )
            }
        }
        .onPreferenceChange(ViewSizePreferenceKey.self) {
            size.wrappedValue = $0 ?? .zero
        }
    }
}

struct ViewSizePreferenceKey: PreferenceKey {
    
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = nextValue() ?? value
    }
    
    static var defaultValue: CGSize? = nil
}
