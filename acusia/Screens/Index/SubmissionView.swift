//
//  SubmissionSheet.swift
//  acusia
//
//  Created by decoherence on 9/14/24.
//
import SwiftUI

struct SubmissionView: View {
    var animationNamespace: Namespace.ID
    @Binding var selectedResult: SearchResult?

    var body: some View {
        if let artwork = selectedResult?.artwork {
            let backgroundColor = artwork.backgroundColor.map { Color($0) } ?? Color.clear

            VStack(spacing: 0) {
                HStack {
                    // Writing symbol
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    VStack {
                        Text(selectedResult?.artistName ?? "")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .matchedGeometryEffect(id: "artistName-\(selectedResult?.id)", in: animationNamespace)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(selectedResult?.title ?? "")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .matchedGeometryEffect(id: "title-\(selectedResult?.id)", in: animationNamespace)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer()
                }
                .padding(24)

                ZStack {
                    ImprintView(animationNamespace: animationNamespace, selectedResult: $selectedResult)
                }
                .frame(width: UIScreen.current?.bounds.size.width, height: UIScreen.current?.bounds.size.width)

                Spacer()
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedResult = nil
                }
            }
            .transition(.scale(scale: 1))
        }
    }
}
