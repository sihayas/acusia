//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

enum RotationAxis: Equatable {
    case topRight, topLeft, bottomLeft, bottomRight

    var value: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch self {
        case .topRight: return (1, 1, 0)
        case .topLeft: return (-1, 1, 0)
        case .bottomLeft: return (-1, -1, 0)
        case .bottomRight: return (1, -1, 0)
        }
    }
}

struct ArtifactView: View {
    @EnvironmentObject private var windowState: HomeState
    @State private var scale: CGFloat = 1
    let entry: EntryModel

    var body: some View {
        let imageUrl = entry.imageUrl

        VStack(spacing: 0) {
            Text(entry.username)
                .foregroundColor(.secondary)
                .font(.system(size: 11, weight: .regular))
                .frame(maxWidth: 240, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 32)

            ZStack {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                } placeholder: {
                    Rectangle()
                }
                .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                .frame(width: 240, height: 240)
                .background(
                    RoundedRectangle(cornerRadius: 45, style: .continuous)
                        .stroke(.white,
                                lineWidth: 4)
                )
                .phaseAnimator(
                    [RotationAxis.topRight, RotationAxis.topLeft, RotationAxis.bottomLeft, RotationAxis.bottomRight]
                ) { content, phase in
                    content.rotation3DEffect(Angle.degrees(6), axis: phase.value, perspective: 0.5)
                } animation: { _ in
                    .spring(duration: 4, bounce: 0, blendDuration: 4)
                }

                ZStack(alignment: .bottomTrailing) {
                    AvatarView(size: 56, imageURL: entry.userImage)
                        .background(
                            Circle()
                                .stroke(.thinMaterial,
                                        lineWidth: 2)
                        )
                        .offset(x: 12, y: 12)

                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(entry.text)
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.thickMaterial.shadow(
                        .inner(color: .white.opacity(0.1), radius: 8, x: 0, y: 0)
                    ),
                    in: ArtifactBubbleWithTail(scale: scale))
                    .foregroundStyle(.secondary)
                    .clipShape(ArtifactBubbleWithTail(scale: scale))
                    .overlay(
                        ArtifactBubbleWithTail(scale: scale)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.bottom, 24)
                    .padding(.trailing, 12)
                }
                .frame(width: 240, height: 240, alignment: .bottomTrailing)
                .shadow(color: .black.opacity(0.4), radius: 8)
            }

            VStack {
                Spacer()
                    .frame(height: 12)
                Text(entry.artistName)
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Text(entry.name)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1)
                    .repeatForever()
            ) {
                scale = 1.2
            }
        }
    }
}

struct WispView: View {
    @EnvironmentObject private var windowState: WindowState
    let entry: EntryModel
    let type: String = "none"

    @State private var scale: CGFloat = 1

    var body: some View {
        let imageUrl = entry.imageUrl
        let blipSize: CGFloat = 52

        VStack(alignment: .leading, spacing: 0) {
            Text(entry.username)
                .foregroundColor(.secondary)
                .font(.system(size: 11, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
                .padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: -12) {
                // Text Bubble, Blip & Replies
                HStack {
                    ZStack(alignment: .topTrailing) {
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            Text(entry.text)
                                .foregroundColor(.white)
                                .font(.system(size: 17))
                                .shadow(
                                    color: Color.black.opacity(0.3),
                                    radius: 3,
                                    x: 0,
                                    y: 2
                                )
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(6)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: WispBubbleWithTail(scale: scale))
                        .clipShape(WispBubbleWithTail(scale: scale))
                        .foregroundStyle(.secondary)

                        BlipView(size: CGSize(width: blipSize, height: blipSize))
                            .padding(.top, -blipSize / 1.5)
                            .padding(.trailing, -18)
                    }

                    if !sampleComments.isEmpty {
                        ZStack {
                            VStack {
                                Spacer()

                                TopCenterToTrailingCenterPath()
                                    .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(maxWidth: 36, maxHeight: 18)
                                    .scaleEffect(x: -1, y: -1)
                            }
                            .frame(width: 36, height: 36)

                            VStack {
                                ZStack {
                                    RadialLayout(radius: 12, offset: 5).callAsFunction {
                                        ForEach(0 ..< 3) { index in
                                            AvatarView(size: [14, 16, 12][index], imageURL: "https://picsum.photos/200/300")
                                        }
                                    }
                                }
                                .frame(width: 36, height: 36)
                            }
                            .offset(x: 0, y: 44)
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                windowState.isSplit.toggle()
                            }
                        }
                    }
                }
                .padding(.leading, 24)
                .zIndex(1)

                // Avatar & Sound
                HStack(alignment: .bottom, spacing: -32) {
                    AvatarView(size: 96, imageURL: entry.userImage)

                    HStack {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white,
                                                lineWidth: 4)
                                )
                        } placeholder: {
                            Rectangle()
                        }
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.4), radius: 8)

                        VStack(alignment: .leading) {
                            Text(entry.artistName)
                                .foregroundColor(.secondary)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)

                            Text(entry.name)
                                .foregroundColor(.white)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1)
                    .repeatForever()
            ) {
                scale = 1.2
            }
        }
    }
}


// if !sampleComments.isEmpty {
//     HStack(spacing: 4) {
//         VStack {
//             BottomCurvePath()
//                 .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
//                 .frame(maxWidth: 36, maxHeight: 18)
//
//             Spacer()
//         }
//         .frame(width: 36, height: 36)
//
//         ZStack {
//             ForEach(0 ..< 3) { index in
//                 AvatarView(size: 14, imageURL: "https://picsum.photos/200/300")
//                     .clipShape(Circle())
//                     .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
//                     .offset(tricornOffset(for: index, radius: 10))
//             }
//         }
//         .frame(width: 36, height: 36)
//
//         Text("33")
//             .foregroundColor(.secondary)
//             .font(.system(size: 13, weight: .semibold))
//     }
// }
