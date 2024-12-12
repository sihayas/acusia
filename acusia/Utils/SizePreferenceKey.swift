//
//  SizePreferenceKey.swift
//  acusia
//
//  Created by decoherence on 12/11/24.
//

import SwiftUI

/// Measures the size of a view and reports it to the parent view.
/// https://www.fivestars.blog/articles/swiftui-share-layout-information/
struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}
