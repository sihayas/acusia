//
//  SecondaryWindow.swift
//  acusia
//
//  Created by decoherence on 1/21/25.
//

import SwiftUI

/// IMPORTANT: Putting a border on the outer stack prevents touch inputs from being passed through.
struct SecondaryView: View {
    @EnvironmentObject private var uiState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            SymmetryView()
                .offset(y: -keyboardHeight)
                .animation(.snappy, value: keyboardHeight)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height + 24
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    self.keyboardHeight = safeAreaInsets.bottom
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            self.keyboardHeight = safeAreaInsets.bottom
            uiState.symmetryState = .feed
            uiState.enableDarkMode()
        }
    }
}
