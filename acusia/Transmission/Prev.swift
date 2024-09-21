//
//  Prev.swift
//  acusia
//
//  Created by decoherence on 9/17/24.
//

import SwiftUI
import Transmission

struct ButtonView: View {
    @State private var isPresented = false
    @State private var progress: CGFloat = 0

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
                transition: .custom,
                isPresented: $isPresented
            ) {
                TransitionReader { proxy in
                    ZStack {
                        Image("maps")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .opacity(proxy.progress)
                        
                        VStack {
                            Text("Hello, world!")
                                .font(.title)
                                .padding()
                            
                            Spacer()
                        }
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
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Prev()
}
