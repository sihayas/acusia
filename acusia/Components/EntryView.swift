//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import BigUIPaging
import SwiftUI

struct Entry: View {
    let entry: APIEntry
    let onDelete: (String) async -> Void

    @Binding var expandedEntryId: String?

    // Entry is halfway past scrollview.
    @State private var isVisible: Bool = false

    // First controls the sheet visibility. Second controls animation.
    @State private var showReplySheet = false
    @State private var animateReplySheet = false

    // Helps to offset the selected entry to the top of the screen.
    @State private var repliesOffset: CGFloat = 0
    @State private var entryHeight: CGFloat = 0

    var body: some View {
        // Entry
        VStack {
            if entry.rating == 2 {
                WispView(entry: entry)
            } else {
                ArtifactView(entry: entry, showReplySheet: $showReplySheet)
                    .scaleEffect(animateReplySheet ? 0.4 : 1, anchor: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .onScrollVisibilityChange(threshold: 0.5) { visibility in
            isVisible = visibility
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        entryHeight = geometry.size.height
                    }
                    .onChange(of: showReplySheet) { _, new in
                        withAnimation {
                            if new {
                                // Measure the top of the entry from the top of the screen.
                                repliesOffset = geometry.frame(in: .global).minY - 32
                                animateReplySheet = true
                                expandedEntryId = entry.id
                            } else {
                                repliesOffset = 0
                                animateReplySheet = false
                                expandedEntryId = nil
                            }
                        }
                    }
            }
        )
        /// Move the entry view to the top of the screen.
        .offset(y: animateReplySheet ? 32 - repliesOffset : 0)
    }
}


class EmojiTextField: UITextField {
    override var textInputMode: UITextInputMode? {
        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
}

struct EmojiTextFieldWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> EmojiTextField {
        let textField = EmojiTextField()
        textField.placeholder = "Enter Emoji"
        return textField
    }

    func updateUIView(_ uiView: EmojiTextField, context: Context) {
        // Update any properties if needed
    }
}

struct ArtifactView: View {
    @Namespace private var namespace
    let entry: APIEntry
    @Binding var showReplySheet: Bool
    @State private var showPopover = false
    @State private var showPopoverAnimate = false
    @State private var showEmojiTextField = false
    @State private var selection: Int = 1

    var body: some View {
        let imageUrl = entry.sound.appleData?.artworkUrl
            .replacingOccurrences(of: "{w}", with: "720")
            .replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"

        VStack(alignment: .leading) {
            Text(entry.author.username)
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.leading)
                .padding(.leading, 64)
                .padding(.bottom, -2)

            HStack(alignment: .bottom, spacing: 8) {
                AvatarView(size: 36, imageURL: entry.author.image)
                    .zIndex(1)

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
                                                    .font(.system(size: 15, weight: .semibold))
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
                                                .frame(height: .infinity)
                                            )
                                        }

                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(entry.sound.appleData?.artistName ?? "Unknown")
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                                    .lineLimit(1)
                                                Text(entry.sound.appleData?.name ?? "Unknown")
                                                    .foregroundColor(.secondary)
                                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                    .lineLimit(1)
                                            }

                                            Spacer()

                                            HeartPath()
                                                .fill(.pink)
                                                .frame(width: 28, height: 26)
                                                .frame(height: 28)
                                                .shadow(radius: 4)
                                                .rotationEffect(.degrees(8))
                                        }
                                        .padding(20)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    }
                                }
                                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 32))
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if !sampleComments.isEmpty {
                HStack(spacing: 4) {
                    VStack {
                        BottomCurvePath()
                            .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(maxWidth: 36, maxHeight: 18)

                        Spacer()
                    }
                    .frame(width: 36, height: 36)

                    ZStack {
                        ForEach(0 ..< 3) { index in
                            AvatarView(size: 14, imageURL: "https://picsum.photos/200/300")
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
                                .offset(tricornOffset(for: index, radius: 10))
                        }
                    }
                    .frame(width: 36, height: 36)
                }
                .onTapGesture {
                    showReplySheet.toggle()
                }
            }
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showReplySheet) {
            ReplySheetView()
        }
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
    @Namespace private var namespace
    let entry: APIEntry
    let type: String = "none"

    var body: some View {
        let imageUrl = entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"

        VStack(alignment: .leading) {
            Text(entry.author.username)
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.leading)
                .padding(.leading, 40)
                .padding(.bottom, -2)

            ZStack(alignment: .bottomLeading) {
                HStack(alignment: .bottom) {
                    AvatarView(size: 36, imageURL: entry.author.image)

                    HStack {
                        // Audiowave image in white
                        Image(systemName: "waveform")
                            .symbolEffect(.variableColor.iterative, options: .repeating)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)

                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                        } placeholder: {
                            Rectangle()
                        }
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )

                        VStack(alignment: .leading) {
                            Text(entry.sound.appleData?.artistName ?? "Unknown")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                            Text(entry.sound.appleData?.name ?? "Unknown")
                                .foregroundColor(.white)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                        }
                        .lineLimit(1) // Restrict to a single line
                        .truncationMode(.tail) // Truncate if it's too long

                        Spacer()
                    }
                }

                if type == "reaction" {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 5, height: 5)
                            .offset(x: -8, y: 6)
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 12, height: 12)
                            .offset(x: 2, y: 2)
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.bottom, 36)
                    .padding(.leading, 20)
                } else {
                    ZStack(alignment: .bottomLeading) {
                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 5, height: 5)
                            .offset(x: 8, y: 6)
                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 12, height: 12)
                            .offset(x: -2, y: 2)
                        Text(entry.text)
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.systemGray6),
                                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.bottom, 40)
                    .padding(.leading, 28)
                    .padding(.trailing, 64)
                }
            }

            if !sampleComments.isEmpty {
                HStack(spacing: 4) {
                    VStack {
                        BottomCurvePath()
                            .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(maxWidth: 36, maxHeight: 18)

                        Spacer()
                    }
                    .frame(width: 36, height: 36)

                    ZStack {
                        ForEach(0 ..< 3) { index in
                            AvatarView(size: 14, imageURL: "https://picsum.photos/200/300")
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
                                .offset(tricornOffset(for: index, radius: 10))
                        }
                    }
                    .frame(width: 36, height: 36)

                    Text("33")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 24)
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
