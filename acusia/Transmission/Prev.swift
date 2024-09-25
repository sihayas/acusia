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
    @State private var showSheet = false
    @State private var isImageVisible = false

    var body: some View {
        Image("maps")
            .resizable()
            .frame(width: 120, height: 120)
            .opacity(showSheet ? 0 : 1)
            .onTapGesture {
                withAnimation {
                    showSheet.toggle()
                }
            }
            .presentation(
                transition: .custom(CustomTransition {
                    isImageVisible = true
                }),
                isPresented: $showSheet
            ) {
                TransitionReader { _ in
                    Image("maps")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .opacity(isImageVisible ? 1 : 0)
                        .onAppear {
                            isImageVisible = false
                        }
                }
            }
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
