//
//  VGrid.swift
//  acusia
//
//  Created by decoherence on 9/1/24.
//
// I created this to help with the search screen un-rendering cells and therefore breaking the match geometry animation as it moved out of view. Thank you to vahotm https://gist.github.com/vahotm/69b750bf1572dc499122095c30f042f7

import Foundation
import SwiftUI

struct VGrid<Cell: View>: View {

    struct CollectionRow<Cell: View>: View {
        let indices: Range<Int>
        let numberOfColumns: Int
        let spacing: CGFloat
        let minHeight: CGFloat
        @ViewBuilder var cellBuilder: (Int) -> Cell

        @ViewBuilder
        var body: some View {
            HStack(spacing: spacing) {
                ForEach(indices, id: \.self) { index in
                    cellBuilder(index)
                        .frame(minHeight: minHeight)
                }
                ForEach(0..<(numberOfColumns - indices.count), id: \.self) { _ in
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    let configuration: VGridConfiguration
    @ViewBuilder var cellBuilder: (Int) -> Cell

    @State private var maxRowHeight: CGFloat = 0.0

    @ViewBuilder
    var body: some View {
        VStack(alignment: configuration.alignment, spacing: configuration.vSpacing) {
            ForEach(ranges, id: \.self) { rowRange in
                CollectionRow(
                    indices: rowRange,
                    numberOfColumns: configuration.numberOfColumns,
                    spacing: configuration.hSpacing,
                    minHeight: maxRowHeight,
                    cellBuilder: cellBuilder)
                .fixedSize(horizontal: false, vertical: true)
                .readSize { size in
                    maxRowHeight = max(size.height, maxRowHeight)
                }
                .frame(minHeight: maxRowHeight)
            }
        }
    }

    private var ranges: [Range<Int>] {
        stride(from: 0, to: configuration.itemsCount, by: configuration.numberOfColumns).map { i in
            let upperBound = min(i + configuration.numberOfColumns, configuration.itemsCount)
            return i..<upperBound
        }
    }

    init(_ configuration: VGridConfiguration, cellBuilder: @escaping (Int) -> Cell) {
        self.configuration = configuration
        self.cellBuilder = cellBuilder
    }
}

struct VGridConfiguration {
    let numberOfColumns: Int
    let itemsCount: Int
    let alignment: HorizontalAlignment
    let hSpacing: CGFloat
    let vSpacing: CGFloat
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
