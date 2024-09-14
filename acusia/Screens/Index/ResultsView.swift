//
//  ResultsView.swift
//  acusia
//
//  Created by decoherence on 9/13/24.
//
import SwiftUI

/// Important: Match Geometry is heavily dependent on where it is on the view hierearchy. For an AsyncImage for example it has be on the outer most. For a shape it has to be above the frame. ScrollClipDisabled was necessary to prevent the cell from being clipped as it went from one part of the parent HStack scrollview to the other. Also, I had to use a custom non-lazy v grid because as soon as the lazy v grid moved away from the view, it un-rendered the cells so match geometry broke.
struct ResultsView: View {
    // VGrid
    @State private var maxRowHeight: CGFloat = 0.0
    
    // Matched Geometry
    var animationNamespace: Namespace.ID

    // Parameters
    @Binding var selectedResult: SearchResult?
    @Binding var searchResults: [SearchResult]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VGrid(VGridConfiguration(
                numberOfColumns: 2,
                itemsCount: searchResults.count,
                alignment: .leading,
                hSpacing: 12,
                vSpacing: 12
            )
            ) { index in
                // Ensure each case returns a valid View
                Group {
                    if let artwork = searchResults[index].artwork {
                        let backgroundColor = artwork.backgroundColor.map { Color($0) } ?? Color.clear

                        ZStack {
                            if selectedResult?.id != searchResults[index].id {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(backgroundColor.mix(with: .black, by: 0.5))
                                    .frame(width: 186, height: 112)
                                    .overlay(
                                        VStack(alignment: .leading) {
                                            AsyncImage(url: artwork.url(width: 1000, height: 1000)) { image in
                                                image
                                                    .resizable()
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.gray.opacity(0.25))
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .matchedGeometryEffect(id: "\(searchResults[index].id)-artwork", in: animationNamespace)
                                            .aspectRatio(contentMode: .fit)

                                            VStack(alignment: .leading) {
                                                Text(searchResults[index].artistName)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .foregroundColor(.white.opacity(0.6))
                                                    .matchedGeometryEffect(id: "artistName-\(searchResults[index].id)", in: animationNamespace)

                                                Text(searchResults[index].title)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                    .foregroundColor(.white)
                                                    .matchedGeometryEffect(id: "title-\(searchResults[index].id)", in: animationNamespace)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(12)
                                    )
                                    .readSize { size in
                                        maxRowHeight = max(size.height, maxRowHeight)
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(.secondary)
                                    .fill(.black)
                                    .frame(width: 186, height: 124)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedResult = searchResults[index]
                            }
                        }
                        .transition(.scale(scale: 1))
                    } else {
                        EmptyView()
                            .frame(width: 186, height: 124)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollClipDisabled()
    }
}
