//
//  Prev.swift
//  acusia
//
//  Created by decoherence on 9/17/24.
//

import SwiftUI
import Transmission

// create a generic srtuct that shows a sheet on button press
struct SheetView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("Show Sheet") {
                isPresented.toggle()
            }
        }
        .sheet(isPresented: $isPresented) {
            Text("Sheet")
                .presentationDetents([.large])
        }
    }
}

struct ButtonView: View {
    @State private var isPresented = false
    @State private var isImageVisible = false

    var body: some View {
        Image("maps")
            .resizable()
            .frame(width: 120, height: 120)
            .onTapGesture {
                withAnimation {
                    isPresented.toggle()
                }
            }
            .presentation(
                transition: setupCustomTransition(),
                isPresented: $isPresented
            ) {
                TransitionReader { _ in
                    Image("maps")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .opacity(isImageVisible ? 1 : 0) // Use opacity to show/hide image
                        .onAppear {
                            isImageVisible = false
                        }
                }
            }
    }

    private func setupCustomTransition() -> PresentationLinkTransition {
        .custom(
            options: .init(),
            SheetTransition {
                isImageVisible = true // Update state when transition completes
            }
        )
    }
}

struct Prev: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                ButtonView()
                ButtonView()
                ButtonView()
                ButtonView()
                SheetView()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Prev()
}
