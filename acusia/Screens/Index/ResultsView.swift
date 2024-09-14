//
//  ResultsView.swift
//  acusia
//
//  Created by decoherence on 9/13/24.
//
import SwiftUI

/// Important: Match Geometry is heavily dependent on where it is on the view hierearchy. For an AsyncImage for example it has be on the outer most. For a shape it has to be above the frame. ScrollClipDisabled was necessary to prevent the cell from being clipped as it went from one part of the parent HStack scrollview to the other. Also, I had to use a custom non-lazy v grid because as soon as the lazy v grid moved away from the view, it un-rendered the cells so match geometry broke.
struct ResultsView: View {
    @State private var maxRowHeight: CGFloat = 0.0
    var animationNamespace: Namespace.ID

    @Binding var selectedResult: SearchResult?
    @Binding var searchResults: [SearchResult]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(searchResults.indices, id: \.self) { index in
                    if let artwork = searchResults[index].artwork {
                        let backgroundColor = artwork.backgroundColor.map { Color($0) } ?? Color.clear

                        ZStack {
                            if selectedResult?.id != searchResults[index].id {
                                HStack {
                                    AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.gray.opacity(0.25))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .matchedGeometryEffect(id: "\(searchResults[index].id)-artwork", in: animationNamespace)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color(backgroundColor), lineWidth: 2)
                                    )

                                    VStack(alignment: .leading) {
                                        Text(searchResults[index].artistName)
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .lineLimit(1)
                                            .foregroundColor(.white.opacity(0.6))

                                        Text(searchResults[index].title)
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .lineLimit(1)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(width: .infinity, height: 48)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedResult = searchResults[index]
                            }
                        }
                    } else {
                        EmptyView()
                            .frame(width: .infinity, height: 112)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 64)
        }
    }
}
