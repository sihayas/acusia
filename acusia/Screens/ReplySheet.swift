//
//  ReplySheet.swift
//  acusia
//
//  Created by decoherence on 9/8/24.
//
import SwiftUI

struct ReplySheetView: View {
    var body: some View {
        ZStack {

            ScrollView {
                LazyVStack(alignment: .leading) {
                    RepliesView(replies: sampleComments) // The content you want to display
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents([.fraction(0.85), .large])
        .presentationCornerRadius(45)
        .presentationBackground(.clear)
        .presentationDragIndicator(.visible)
    }
}

struct RepliesView: View {
    @State private var showReplyChildren: Reply? = nil

    var replies: [Reply]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(replies) { reply in
                if showReplyChildren == nil || showReplyChildren == reply {
                    ReplyView(reply: reply, showReplyChildren: $showReplyChildren)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showReplyChildren)
                }
            }
        }
    }
}

struct ReplyView: View {
    let reply: Reply
    @Binding var showReplyChildren: Reply?

    var body: some View {
        var isExpanded: Bool {
            showReplyChildren == reply
        }

        var childrenCount: Int {
            reply.children.count
        }

        VStack(alignment: .leading) {
            // Comment
            HStack(alignment: .bottom, spacing: 0) {
                // Thread
                VStack {
                    Capsule()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 3, height: .infinity)

                    AvatarView(size: 32, imageURL: reply.avatarURL)
                }

                // Text bubble
                VStack(alignment: .leading, spacing: 4) {
                    Text(reply.username)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.leading, 26)

                    ZStack(alignment: .bottomLeading) {
                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 12, height: 12)
                            .offset(x: 0, y: 0)

                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 6, height: 6)
                            .offset(x: -8, y: 2)

                        Text(reply.text ?? "")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding([.leading], 12)
                    .padding([.bottom], 4)
                    .overlay(
                        ZStack {
                            HeartTapSmall(isTapped: false, count: 0)
                                .offset(x: 12, y: -14)
                        },
                        alignment: .topTrailing
                    )
                }
            }

            // Children
            if !reply.children.isEmpty {
                // Expand thread capsule
                HStack(spacing: -4) {
                    if !isExpanded {
                        Capsule()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 3, height: 16)
                            .frame(width: 32)

                        Text("\(childrenCount) threads")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    } else {
                        LoopPath()
                            .stroke(Color(UIColor.systemGray6),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 30, height: 20)
                            .frame(width: 32)
                            .transition(.scale)

                        Text("Hide threads")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    withAnimation {
                        if isExpanded {
                            showReplyChildren = nil
                        } else {
                            showReplyChildren = reply
                        }
                    }
                }

                if showReplyChildren == reply {
                    RepliesView(replies: reply.children)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

class Reply: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let text: String?
    let avatarURL: String
    var children: [Reply] = []

    init(username: String, text: String? = nil, avatarURL: String, children: [Reply] = []) {
        self.username = username
        self.text = text
        self.avatarURL = avatarURL
        self.children = children
    }

    // Conform to Equatable
    static func == (lhs: Reply, rhs: Reply) -> Bool {
        return lhs.id == rhs.id
    }
}

// Sample comments with nesting
let sampleComments: [Reply] = [
    Reply(
        username: "johnnyD",
        text: "fr this is facts",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "janey",
                text: "omg thank u johnny lol we gotta talk about this more",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "mikez",
                        text: "idk janey i feel like it’s different tho can u explain more",
                        avatarURL: "https://picsum.photos/200/200",
                        children: [
                            Reply(
                                username: "janey",
                                text: "mike i get u but it’s like the bigger picture yk",
                                avatarURL: "https://picsum.photos/200/200",
                                children: [
                                    Reply(
                                        username: "sarah_123",
                                        text: "yeah janey got a point tho",
                                        avatarURL: "https://picsum.photos/200/200",
                                        children: [
                                            Reply(
                                                username: "johnnyD",
                                                text: "lowkey agree with sarah",
                                                avatarURL: "https://picsum.photos/200/200",
                                                children: [
                                                    Reply(
                                                        username: "mikez",
                                                        text: "ok i see it now",
                                                        avatarURL: "https://picsum.photos/200/200",
                                                        children: [
                                                            Reply(
                                                                username: "janey",
                                                                text: "glad we’re all on the same page now lol",
                                                                avatarURL: "https://picsum.photos/200/200"
                                                            )
                                                        ]
                                                    )
                                                ]
                                            )
                                        ]
                                    )
                                ]
                            )
                        ]
                    )
                ]
            ),
            Reply(
                username: "sarah_123",
                text: "i think it’s a bit more complicated than that",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "johnnyD",
                        text: "yeah i see what u mean",
                        avatarURL: "https://picsum.photos/200/200",
                        children: [
                            Reply(
                                username: "sarah_123",
                                text: "exactly johnny",
                                avatarURL: "https://picsum.photos/200/200"
                            )
                        ]
                    ),
                    Reply(
                        username: "janey",
                        text: "i disagree",
                        avatarURL: "https://picsum.photos/200/200"
                    ),
                    Reply(
                        username: "mikez",
                        text: "i don’t think it’s that simple",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            )
        ]
    ),
    Reply(
        username: "sarah_123",
        text: "i think it’s a bit more complicated than that",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "johnnyD",
                text: "yeah i see what u mean",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "sarah_123",
                        text: "exactly johnny",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            ),
            Reply(
                username: "janey",
                text: "i disagree",
                avatarURL: "https://picsum.photos/200/200"
            ),
            Reply(
                username: "mikez",
                text: "i don’t think it’s that simple",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "mike",
        text: "i don’t think it’s that simple",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "sarah_123",
                text: "mike i think you’re missing the point",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "mike",
                        text: "sarah i get it but it’s not that black and white",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            ),
            Reply(
                username: "johnnyD",
                text: "mike i think you’re right",
                avatarURL: "https://picsum.photos/200/200"
            ),
            Reply(
                username: "janey",
                text: "mike i think you’re wrong",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "johnnyD",
        text: "mike i think you’re right",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "janey",
        text: "mike i think you’re wrong",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "mike",
        text: "i don’t think it’s that simple",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "sarah_123",
                text: "mike i think you’re missing the point",
                avatarURL: "https://picsum.photos/200/200",
                children: [
                    Reply(
                        username: "mike",
                        text: "sarah i get it but it’s not that black and white",
                        avatarURL: "https://picsum.photos/200/200"
                    )
                ]
            ),
            Reply(
                username: "johnnyD",
                text: "mike i think you’re right",
                avatarURL: "https://picsum.photos/200/200"
            ),
            Reply(
                username: "janey",
                text: "mike i think you’re wrong",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    )
]

struct BottomCurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the curve
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width / 2))

        // Draw the rounded corner curve to the right center
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct TopBottomCurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the top curve to the right
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + rect.width / 2),
                          control: CGPoint(x: rect.maxX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the bottom curve
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.width / 2))

        // Draw the bottom curve to the left
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}

struct LoopPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0.95*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.75*height))
        path.addCurve(to: CGPoint(x: 0.20953*width, y: 0.26027*height), control1: CGPoint(x: 0.5*width, y: 0.51429*height), control2: CGPoint(x: 0.36032*width, y: 0.26027*height))
        path.addCurve(to: CGPoint(x: 0.03333*width, y: 0.50961*height), control1: CGPoint(x: 0.05874*width, y: 0.26027*height), control2: CGPoint(x: 0.03333*width, y: 0.41697*height))
        path.addCurve(to: CGPoint(x: 0.20956*width, y: 0.74652*height), control1: CGPoint(x: 0.03333*width, y: 0.60226*height), control2: CGPoint(x: 0.06435*width, y: 0.74652*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.25*height), control1: CGPoint(x: 0.3771*width, y: 0.74652*height), control2: CGPoint(x: 0.5*width, y: 0.50267*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.05*height))
        return path
    }
}

// Helper function to calculate avatar offsets
func tricornOffset(for index: Int, radius: CGFloat = 12) -> CGSize {
    switch index {
    case 0: // Top Center
        return CGSize(width: 0, height: -radius)
    case 1: // Bottom Left
        return CGSize(width: -radius*cos(.pi / 6), height: radius*sin(.pi / 6))
    case 2: // Bottom Right
        return CGSize(width: radius*cos(.pi / 6), height: radius*sin(.pi / 6))
    default:
        return .zero
    }
}

//UnevenRoundedRectangle(topLeadingRadius: 45, bottomLeadingRadius: 55, bottomTrailingRadius: 55, topTrailingRadius: 45, style: .continuous)
//    .stroke(.white.opacity(0.1), lineWidth: 1)
//    .foregroundStyle(.clear)
//    .background(
//        BlurView(style: .dark, backgroundColor: .black, blurMutingFactor: 0.75)
//            .edgesIgnoringSafeArea(.all)
//    )
//    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//    .padding(1)
//    .ignoresSafeArea()
