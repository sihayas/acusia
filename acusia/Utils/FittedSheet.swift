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
        modifier(FittedSheetModifier(isPresented: isPresented, onDismiss: onDismiss, sheetContent: content))
    }
}

struct FittedSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    let sheetContent: () -> SheetContent

    @State private var size: CGSize = .init(width: UIScreen.main.bounds.width, height: 600)

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                ZStack {
                    UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 55, bottomTrailingRadius: 55, topTrailingRadius: 32, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                        .foregroundStyle(.clear)
                        .background(
                            BlurView(style: .dark, backgroundColor: .black, blurMutingFactor: 0.75)
                                .edgesIgnoringSafeArea(.all)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(1)
                        .ignoresSafeArea()

                    // Sheet content
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
                }
                .presentationDetents([.height(size.height), .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(32)
                .presentationBackground(.clear)
            }
    }
}

//
// struct SheetHeightModifier: ViewModifier {
//    @Binding var height: CGFloat
//
//    func body(content: Content) -> some View {
//        content
//            .fixedSize(horizontal: false, vertical: true)
//            .background(
//            GeometryReader { reader -> Color in
//                height = reader.size.height
//                print(height)
//                return Color.clear
//            }
//        )
//    }
// }
//
// struct PresentationDetentModifier: ViewModifier {
//    @Binding var height: CGFloat
//
//    func body(content: Content) -> some View {
//        content
//            .modifier(SheetHeightModifier(height: $height))
//            .presentationDetents([.height(height)])
//    }
// }
//
// extension View {
//    func flexiblePresentationDetents(height: Binding<CGFloat>) -> some View {
//        self.modifier(PresentationDetentModifier(height: height))
//    }
// }
