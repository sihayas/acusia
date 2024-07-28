//
//  AnimationProgress.swift
//  GooeyShareButton
//
//  Created by Leandro Bastos on 13/06/23.
//

import SwiftUI

extension View {
    @ViewBuilder
    func animationProgress<Value: VectorArithmetic>(endValue: Value, progress: @escaping(Value) -> ()) -> some View {
        self.modifier(AnimationProgress(endVAlue: endValue, onChange: progress))
    }
}
struct AnimationProgress<Value: VectorArithmetic>: ViewModifier, Animatable {
    var animatableData: Value {
        didSet {
            sendProgress()
        }
    }
    var endVAlue: Value
    var onChange: (Value) -> ()

    init(endVAlue: Value, onChange: @escaping (Value) -> Void) {
        self.animatableData = endVAlue
        self.endVAlue = endVAlue
        self.onChange = onChange
    }

    func body(content: Content) -> some View {
        content
    }

    func sendProgress() {
        DispatchQueue.main.async {
            onChange(animatableData)
        }
    }
}
