//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import BigUIPaging
import SwiftUI
import Transmission

struct ArtifactView: View {
    @EnvironmentObject private var windowState: WindowState

    let entry: EntryModel

    @Binding var showReplySheet: Bool
    @State private var showPopover = false
    @State private var showPopoverAnimate = false
    @State private var showEmojiTextField = false
    @State private var selection: Int = 1

    var body: some View {
        let imageUrl = entry.imageUrl

        VStack {
            // Card stack
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .foregroundStyle(.ultraThickMaterial)
                            .background(
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                } placeholder: {
                                    Rectangle()
                                }
                            )
                            .overlay {
                                ZStack(alignment: .bottomTrailing) {
                                    if !showPopover {
                                        VStack {
                                            Text(entry.text)
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .semibold))
                                                .multilineTextAlignment(.leading)
                                        }
                                        .padding([.horizontal, .top], 20)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .mask(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: .black, location: 0),
                                                    .init(color: .black, location: 0.75),
                                                    .init(color: .clear, location: 0.825)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(maxHeight: .infinity)
                                        )
                                    }

                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(entry.artistName)
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                                .lineLimit(1)
                                            Text(entry.name)
                                                .foregroundColor(.white)
                                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        HeartPath()
                                            .fill(.black)
                                            .frame(width: 28, height: 28)
                                            .frame(height: 28)
                                            .shadow(radius: 4)
                                            .rotationEffect(.degrees(4))
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .contextMenu {
                                Button {
                                    showEmojiTextField = true
                                } label: {
                                    Label("Open Emoji Keyboard", systemImage: "keyboard")
                                }
                            }
                            .popover(isPresented: $showPopover, attachmentAnchor: .point(.topLeading), arrowEdge: .bottom) {
                                ScrollView {
                                    Text(entry.text)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .font(.system(size: 15, weight: .regular))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 272)
                                .presentationCompactAdaptation(.popover)
                                .presentationBackground(.ultraThinMaterial)
                            }
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showPopoverAnimate.toggle()
                                }

                                // Delay the popover presentation or dismissal after the animation starts
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    showPopover = showPopoverAnimate
                                }
                            }
                            .onChange(of: showPopover) { _, value in
                                // If the popover is dismissed (showPopover = false), reverse the animation state
                                if !value {
                                    withAnimation(.spring()) {
                                        showPopoverAnimate = false
                                    }
                                }
                            }
                            .frame(height: showPopoverAnimate ? 68 : 280)

                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .background(.clear)
                            .overlay(alignment: .bottom) {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                } placeholder: {
                                    Rectangle()
                                }
                            }
                    }
                }
            }
            .pageViewStyle(.customCardDeck)
            .pageViewCardShadow(.visible)
            .frame(width: 204, height: 280)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }

    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}

struct WispView: View {
    let entry: EntryModel
    let type: String = "none"

    @State private var scale: CGFloat = 1

    var body: some View {
        let imageUrl = entry.imageUrl

        VStack(alignment: .leading, spacing: 0) {
            Text(entry.username)
                .foregroundColor(.secondary)
                .font(.system(size: 11, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
                .padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: -12) {
                
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(entry.text)
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    .ultraThinMaterial
                        .shadow(
                            .inner(color: .white.opacity(0.1), radius: 8, x: 0, y: 0)
                        ),
                    in: WispBubbleWithTail(scale: scale)
                )
                .clipShape(WispBubbleWithTail(scale: scale))
                .padding(.horizontal, 24)
                .zIndex(1)

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

struct WispBubbleWithTail: Shape {
    var scale: CGFloat

    func path(in rect: CGRect) -> Path {
        let bubbleRect = rect
        let bubble = RoundedRectangle(cornerRadius: 24, style: .continuous)
            .path(in: bubbleRect)

        let tailSize: CGFloat = 12 * scale // Scale the tail size
        let tailOffsetX: CGFloat = bubbleRect.width / 2 - tailSize / 2 - 112
        let tailOffsetY: CGFloat = bubbleRect.height - (tailSize - 8)

        // Create the tail (circle)
        let tailRect = CGRect(
            x: bubbleRect.minX + tailOffsetX,
            y: bubbleRect.minY + tailOffsetY,
            width: tailSize,
            height: tailSize
        )
        let tail = Circle().path(in: tailRect)

        let secondCircleSize: CGFloat = 6 * scale
        let secondCircleOffsetX = tailRect.minX - secondCircleSize
        let secondCircleOffsetY = tailRect.maxY
        let secondCircleRect = CGRect(
            x: secondCircleOffsetX,
            y: secondCircleOffsetY,
            width: secondCircleSize,
            height: secondCircleSize
        )
        let secondCircle = Circle().path(in: secondCircleRect)

        let combined = bubble.union(tail).union(secondCircle)

        return combined
    }

    var animatableData: CGFloat {
        get { scale }
        set { scale = newValue }
    }
}

struct VerticalSquigglyLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let amplitude: CGFloat = 5 // Lower amplitude for less squiggle
        let wavelength: CGFloat = 40 // Higher wavelength for gentler squiggle

        // Start straight
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height * 0.1)) // 10% of the height as straight

        // Draw squiggly part
        var y: CGFloat = rect.height * 0.1
        while y < rect.height * 0.9 {
            let x = sin(y / wavelength * .pi * 2) * amplitude + rect.midX
            path.addLine(to: CGPoint(x: x, y: y))
            y += 1
        }

        // End straight
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))

        return path
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
