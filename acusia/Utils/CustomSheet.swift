//
//  CustomSheet.swift
//  acusia
//
//  Created by decoherence on 9/7/24.
//
/// Creates a sheet that is presented with a height of the content inside.
/// Mainly for showing long winded Artifacts.
import SwiftUI

public extension View {
    func fittedSheet<SheetContent: View>(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void = {}, content: @escaping () -> SheetContent) -> some View {
        self.modifier(FittedSheetModifier(isPresented: isPresented, onDismiss: onDismiss, sheetContent: content))
    }
}

struct FittedSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    let sheetContent: () -> SheetContent
    
    @State private var size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 600) // Initial size
    
    func body(content: Content) -> some View {
        content // The original view that this modifier is applied to
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                sheetContent()
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: SizePreferenceKey.self, value: proxy.size)
                        }
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { newSize in
                        size = newSize
                    }
                    .presentationDetents([.height(size.height), .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
                    .presentationBackground(.thinMaterial)
            }
    }
}
