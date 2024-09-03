//
//  SearchBar.swift
//  acusia
//
//  Created by decoherence on 8/30/24.
//
import SwiftUI

struct SearchBar: View {
    @StateObject private var auth = Auth.shared

    @Binding var searchText: String
    @Binding var entryText: String
    @Binding var selectedResult: SearchResult?

    var animationNamespace: Namespace.ID

    var body: some View {
        HStack {
            if let result = selectedResult {
                AsyncImage(url: URL(string: auth.user?.image ?? "")) { image in
                    image
                        .resizable()
                } placeholder: {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 24, height: 24)
                }
                .clipShape(Circle())
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .transition(.blurReplace(.upUp))
                .zIndex(1)
            }

            ZStack {
                if selectedResult == nil {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.thinMaterial)
                        .matchedGeometryEffect(id: "input-bar", in: animationNamespace)
                        .frame(height: 48)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                
                                ZStack {
                                    TextField("Index", text: $searchText, axis: .horizontal)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .font(.system(size: 15))
                                        .matchedGeometryEffect(id: "input-field", in: animationNamespace)
                                }
                            }
                            .padding(.horizontal, 16)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.black)
                        .matchedGeometryEffect(id: "input-bar", in: animationNamespace)
                        .frame(height: 36)
                        .overlay(
                            HStack {
                                ZStack {
                                    TextField("Share album...", text: $entryText, axis: .vertical)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .font(.system(size: 15))
                                    
                                        .matchedGeometryEffect(id: "input-field", in: animationNamespace)
                                }
                            }
                                .padding(.horizontal, 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
    }
}
