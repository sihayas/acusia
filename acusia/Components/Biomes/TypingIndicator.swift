//
//  TypingIndicator.swift
//  acusia
//
//  Created by decoherence on 12/10/24.
//
import SwiftUI

struct TypingIndicator: View {
    var body: some View {
        Image(systemName: "ellipsis")
            .fontWeight(.bold)
            .font(.system(size: 21))
            .foregroundStyle(Color(.systemGray2))
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color(.systemGray6), in: MessageTail())
            .padding(.bottom, 4)
    }
}
