//
//  d.swift
//  acusia
//
//  Created by decoherence on 10/9/24.
//

//
//  ContentView.swift
//  TextRendererAPI
//
//  Created by Matteo Buompastore on 17/06/24.
//

import SwiftUI

struct PixellatePreview: View {
    @State private var reveal: Bool = false
    @State private var revealProgress: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                let apiKey = Text("2387jdfkfnkdf")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .customAttribute(APIKeyAttribute())
                
                Text("\(apiKey)")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .foregroundStyle(.white)
                    .textRenderer(RevealRenderer(progress: revealProgress))
                    .padding(.vertical, 20)
                
                Button {
                    reveal.toggle()
                    withAnimation(.smooth) {
                        revealProgress = reveal ? 1 : 0
                    }
                } label: {
                    Text(reveal ? "Hide Key" : "Show Key")
                        .padding(.horizontal, 25)
                        .padding(.vertical, 2)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.black)
                
                Spacer(minLength: 0)
            }
            .padding(15)
        }
    }
}

struct APIKeyAttribute: TextAttribute {}

struct RevealRenderer: TextRenderer, Animatable {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set {
            progress = newValue
        }
    }
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let allLines = layout.flatMap { $0 }
        print(allLines.count)
        // let allRunns = allLines.flatMap({ $0 })
        
        for line in allLines {
            if let _ = line[APIKeyAttribute.self] {
                var localContext = ctx
                
                let pixellateProgress: CGFloat = 5 - (4.999 * progress)
                let pixellatedFilter = GraphicsContext.Filter
                    .distortionShader(ShaderLibrary.pixellate(.float(pixellateProgress)), maxSampleOffset: .zero)
                
                localContext.addFilter(pixellatedFilter)
                localContext.draw(line)
            } else {
                var localContext = ctx
                localContext.draw(line)
            }
        }
    }
}

#Preview {
    PixellatePreview()
}
