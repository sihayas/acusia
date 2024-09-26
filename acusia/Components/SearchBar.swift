//
//  SearchBar.swift
//  acusia
//
//  Created by decoherence on 8/30/24.
//
import SwiftUI

enum AnimationPhase: CaseIterable {
    case start, end
}

struct SearchBar: View {
    @EnvironmentObject var windowState: WindowState
    @EnvironmentObject var auth: Auth
    @EnvironmentObject var musicKitManager: MusicKit

    @Binding var searchText: String
    @Binding var entryText: String

    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            let _ = windowState.showSearchSheet

            if !windowState.showSearchSheet {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.thinMaterial)
                    .matchedGeometryEffect(id: "input-bar", in: animationNamespace)
                    .frame(width: 64, height: 32)
                    .overlay(
                        ZStack {
                            TextField("Index", text: $searchText, axis: .horizontal)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                                .opacity(0)
                                .matchedGeometryEffect(id: "input-field", in: animationNamespace)
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13))
                                .matchedGeometryEffect(id: "input-glass", in: animationNamespace)
                        }
                    )
                    .onTapGesture {
                        windowState.showSearchSheet.toggle()
                    }

            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.black)
                    .matchedGeometryEffect(id: "input-bar", in: animationNamespace)
                    .frame(height: 48)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13))
                                .matchedGeometryEffect(id: "input-glass", in: animationNamespace)

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
                    .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 40)
                    .rotation3DEffect(
                        .degrees(windowState.jumpTrigger ? -180 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.5
                    )
                    .offset(y: windowState.jumpTrigger ? 80 : 0)
                    .animation(.spring(), value: windowState.jumpTrigger)
//                    .phaseAnimator(AnimationPhase.allCases, trigger: windowState.jumpTrigger) { content, phase in
//                        content
//                            .scaleEffect(phase == .start ? 1 : 1.05)
//                            .offset(y: phase == .start ? 0 : 128)
//                    } animation: { phase in
//                        switch phase {
//                        case .start, .end: .spring(duration: 0.5, bounce: 0.7)
//                        }
//                    }
            }
        }
        .animation(.spring(), value: windowState.showSearchSheet)
        .onAppear {
            Task { await performSearch(query: searchText) }
        }
        .onChange(of: searchText) { _, query in
            Task { await performSearch(query: query) }
        }
    }

    private func performSearch(query: String) async {
        await musicKitManager.loadCatalogSearchTopResults(searchTerm: query)
    }
}

// if let result = selectedResult {
//    AsyncImage(url: URL(string: auth.user?.image ?? "")) { image in
//        image
//            .resizable()
//    } placeholder: {
//        Circle()
//            .fill(.thinMaterial)
//            .frame(width: 24, height: 24)
//    }
//    .clipShape(Circle())
//    .aspectRatio(contentMode: .fit)
//    .frame(width: 32, height: 32)
//    .transition(.blurReplace(.upUp))
//    .zIndex(1)
// }
//
// RoundedRectangle(cornerRadius: 18, style: .continuous)
//    .fill(.black)
//    .matchedGeometryEffect(id: "input-bar", in: animationNamespace)
//    .frame(height: 36)
//    .overlay(
//        HStack {
//            ZStack {
//                TextField("Share album...", text: $entryText, axis: .vertical)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .foregroundColor(.white)
//                    .font(.system(size: 15))
//                    .matchedGeometryEffect(id: "input-field", in: animationNamespace)
//            }
//        }
//        .padding(.horizontal, 12)
//    )
//    .overlay(
//        RoundedRectangle(cornerRadius: 18, style: .continuous)
//            .stroke(.white.opacity(0.1), lineWidth: 1)
//    )
