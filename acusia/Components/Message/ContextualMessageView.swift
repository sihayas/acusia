//
//  ContextualMessageView.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import SwiftUI

struct ContextualMessageView: View {
    @State private var parentAttachmentSize: CGSize = .zero
    @State private var textBubbleSize: CGSize = .zero
    @State private var verticalSpacing: CGFloat = 0
    
    let entity: Entity
    let blipXOffset: CGFloat = 92
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .bottom, spacing: -blipXOffset) {
                ContextualTextBubbleView(entity: entity)
                    .alignmentGuide(VerticalAlignment.bottom) { _ in 8 }
                    .measure($textBubbleSize)
                    .padding(.bottom, 4)
            }
            .onChange(of: textBubbleSize.width) {
                /// If the width of the top is greater than the width of the text bubble minus 16, push the top down.
                verticalSpacing = parentAttachmentSize.width > (textBubbleSize.width) ? 0 : 4
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entity.username)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
            .alignmentGuide(VerticalAlignment.top) { d in d.height + verticalSpacing }
            .measure($parentAttachmentSize)
        }
    }
}
