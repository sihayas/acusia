//
//  ReplyView.swift
//  acusia
//
//  Created by decoherence on 10/1/24.
//

import SwiftUI

struct ReplyView: View {
    let reply: Reply
    let isCollapsed: Bool

    var body: some View {
        let background: Color = isCollapsed ? .black : Color(UIColor.systemGray6)
        let strokeColor: Color = isCollapsed ? Color(UIColor.systemGray6) : .black

        VStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 0) {
                AvatarView(size: 32, imageURL: reply.avatarURL)

                VStack(alignment: .leading, spacing: 2) {
                    Text(reply.username)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)

                    ZStack(alignment: .bottomLeading) {
                        Circle()
                            .stroke(strokeColor, lineWidth: 1)
                            .fill(background)
                            .frame(width: 6, height: 6)
                            .offset(x: -6, y: 4)

                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            Text(reply.text ?? "")
                                .foregroundColor(.white)
                                .font(.system(size: isCollapsed ? 13 : 17))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(isCollapsed ? 1 : nil)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .overlay(
                            BubbleWithTail()
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .background(background, in: BubbleWithTail())
                    }
                    .padding([.leading], 8)
                    .padding([.bottom], 4)
                }
            }
            .animation(.spring(), value: isCollapsed)

            // Children
            // if !reply.children.isEmpty {
            //     Capsule()
            //         .fill(Color(UIColor.systemGray6))
            //         .frame(width: 3)
            //         .frame(width: 32)
            //     // Expand thread capsule
            //     HStack(spacing: -4) {
            //         LoopPath()
            //             .stroke(Color(UIColor.systemGray6),
            //                     style: StrokeStyle(lineWidth: 3, lineCap: .round))
            //             .frame(width: 30, height: 20)
            //             .frame(width: 32)
            //             .transition(.scale)
            //         Text("4 threads")
            //             .font(.system(size: 11, weight: .medium, design: .rounded))
            //             .foregroundColor(.secondary)
            //     }
            // }
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

    static func == (lhs: Reply, rhs: Reply) -> Bool {
        return lhs.id == rhs.id
    }
}

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
        text: "i don’t think it’s that simple. also there is a lot of other stuff, like this. if you want to know more, ask me. otherwise, i’m happy to help",
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
    ),

    Reply(
        username: "alex_b",
        text: "I disagree with you, Janey. I believe your perspective doesn't fully consider all the variables involved in this situation.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "jessica_w",
        text: "Mike, you're oversimplifying this issue. There are multiple layers we need to delve into before drawing any conclusions.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "daniel_r",
        text: "That's an interesting point, but I don't see it that way. Perhaps there's another angle we should explore to get a better understanding.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "emma_k",
        text: "Janey has a valid point, Mike. Maybe we should take her thoughts into consideration before moving forward.",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "mike",
                text: "I hear you, but I still think I'm right. I've looked into it extensively and believe my stance holds.",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "george",
        text: "This conversation is going in circles. Perhaps we should take a step back and reassess our approaches.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "john_doe",
        text: "Sarah_123, I agree with you wholeheartedly. Your insights really highlight the core of the issue.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "jane_d",
        text: "I think everyone's missing the main point here. Let's try to refocus on what's truly important in this discussion.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "tina_l",
        text: "Can we all just agree to disagree? It seems we're not going to reach a consensus anytime soon.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Reply(
        username: "matt_w",
        text: "Mike, you're totally missing the bigger picture. There's more at stake here than what you're considering.",
        avatarURL: "https://picsum.photos/200/200",
        children: [
            Reply(
                username: "mike",
                text: "That's fair, Matt. But consider this perspective, which I think sheds new light on the matter...",
                avatarURL: "https://picsum.photos/200/200"
            )
        ]
    ),
    Reply(
        username: "lucy_h",
        text: "This is getting way too heated. Maybe we should all take a moment to cool down before continuing.",
        avatarURL: "https://picsum.photos/200/200"
    )
]
