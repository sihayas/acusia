//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

struct EntryView: View {
    @EnvironmentObject private var windowState: WindowState

    let entry: EntryModel
    let strokeColor = Color(UIColor.systemGray5)

    @Namespace var animation
    @State private var selected: EntryModel?

    var body: some View {
        // Outer Container
        VStack(alignment: .leading, spacing: 0) {
            // Inner (Replies)
            VStack(spacing: 8) {
                /// Root
                HStack(alignment: .bottom, spacing: 8) {
                    AvatarView(size: 40, imageURL: entry.userImage)
                        .overlay(alignment: .topLeading) {
                            ZStack {
                                AsyncImage(url: URL(string: entry.imageUrl)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .padding(2)
                                .background(Circle().fill(strokeColor))
                            }
                            .frame(width: 56, height: 56)
                            .background(strokeColor, in: SoundBubbleWithTail())
                            .offset(x: 0, y: -48)
                            .shadow(color: .black.opacity(0.15), radius: 4)
                        }
                        .zIndex(1)

                    ReplyBubble(text: entry.text, username: entry.username, artist: entry.artistName, album: entry.name, color: strokeColor)

                    Spacer(minLength: 0)
                }

                /// First Reply (Direct)
                HStack(alignment: .bottom, spacing: 8) {
                    VStack {
                        Capsule()
                            .fill(strokeColor)
                            .frame(width: 4)

                        AvatarView(size: 40, imageURL: "https://i.pinimg.com/736x/41/6d/33/416d33a61850d826a2c4781d78e2341f.jpg")
                    }
                    .frame(maxHeight: .infinity)

                    ReplyBubble(text: "autolux?", username: "ben", color: strokeColor)

                    Spacer(minLength: 8)
                }

                /// Second Reply (Indirect)
                VStack(spacing: 8) {
                    // Parent
                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .fill(strokeColor)
                                .frame(width: 4, height: 8)

                            LoopPath()
                                .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 32, height: 24)

                            AvatarView(size: 24, imageURL: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif")
                                .frame(width: 40)
                        }
                        .frame(maxHeight: .infinity)

                        ReplyOutlineBubble(text: "No and tbh vultures 1 clears both🦅", username: "qwertyyy")

                        Spacer(minLength: 8)
                    }

                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .fill(strokeColor)
                                .frame(width: 4)

                            AvatarView(size: 40, imageURL: "https://i.pinimg.com/474x/ca/a6/c7/caa6c70c24e6705894a36755fdba4fca.jpg")
                        }
                        .frame(maxHeight: .infinity)

                        ReplyBubble(text: "in what world lmao", username: "august", color: strokeColor)

                        Spacer(minLength: 8)
                    }
                    .frame(maxHeight: .infinity) // Important!
                }

                /// Third Reply
                VStack(spacing: 8) {
                    // Parent
                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .fill(strokeColor)
                                .frame(width: 4, height: 8)

                            LoopPath()
                                .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 32, height: 24)

                            AvatarView(size: 24, imageURL: "https://i.pinimg.com/736x/c9/00/97/c90097f2cca68e76fc40831ba96dc9a5.jpg")
                                .frame(width: 40)
                        }
                        .frame(maxHeight: .infinity)

                        ReplyOutlineBubble(text: "don’t piss me off WLR was the blueprint", username: "lancey_fouxx")

                        Spacer(minLength: 8)
                    }

                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .fill(strokeColor)
                                .frame(width: 4)

                            AvatarView(size: 40, imageURL: "https://i.pinimg.com/474x/fd/f1/21/fdf12119ecb977a68bc10d185dbb2523.jpg")
                        }
                        .frame(maxHeight: .infinity)

                        ReplyBubble(text: "Im a fan of both but wlr is wayyyyyyyy better, my fav album", username: "zack+", color: strokeColor)

                        Spacer(minLength: 8)
                    }
                    .frame(maxHeight: .infinity) // Important!
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            .ultraThickMaterial,
            in: RoundedRectangle(cornerRadius: 45, style: .continuous)
        )
        .onTapGesture {
            selected = entry

        }
        .matchedTransitionSource(id: entry.id, in: animation)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .sheet(item: $selected) { entry in
            DetailView(entry: entry)
                .navigationTransition(.zoom(sourceID: entry.id, in: animation))
                .presentationBackground(.black)
        }
    }
}

struct DetailView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @State var didAppear = false
    
    let entry: EntryModel
    let strokeColor = Color(UIColor.systemGray6)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 45, style: .continuous)
                .fill(.ultraThickMaterial)
                .opacity(didAppear ? 0 : 1)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 8) {
                    /// Root
                    HStack(alignment: .bottom, spacing: 8) {
                        AvatarView(size: 40, imageURL: entry.userImage)
                            .overlay(alignment: .topLeading) {
                                ZStack {
                                    AsyncImage(url: URL(string: entry.imageUrl)) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        Rectangle()
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .padding(2)
                                    .background(Circle().fill(strokeColor))
                                }
                                .frame(width: 56, height: 56)
                                .background(strokeColor, in: SoundBubbleWithTail())
                                .offset(x: 0, y: -48)
                                .shadow(color: .black.opacity(0.15), radius: 4)
                            }
                            .zIndex(1)
                        
                        ReplyBubble(text: entry.text, username: entry.username, artist: entry.artistName, album: entry.name, color: strokeColor)
                        
                        Spacer(minLength: 0)
                    }
                    
                    /// First Reply (Direct)
                    HStack(alignment: .bottom, spacing: 8) {
                        VStack {
                            Capsule()
                                .fill(strokeColor)
                                .frame(width: 4)
                            
                            AvatarView(size: 40, imageURL: "https://i.pinimg.com/736x/41/6d/33/416d33a61850d826a2c4781d78e2341f.jpg")
                        }
                        .frame(maxHeight: .infinity)
                        
                        ReplyBubble(text: "autolux?", username: "ben", color: strokeColor)
                        
                        Spacer(minLength: 8)
                    }
                    
                    /// Second Reply (Indirect)
                    VStack(spacing: 8) {
                        // Parent
                        HStack(alignment: .bottom, spacing: 8) {
                            VStack {
                                Capsule()
                                    .fill(strokeColor)
                                    .frame(width: 4, height: 8)
                                
                                LoopPath()
                                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 32, height: 24)
                                
                                AvatarView(size: 24, imageURL: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif")
                                    .frame(width: 40)
                            }
                            .frame(maxHeight: .infinity)
                            
                            ReplyOutlineBubble(text: "No and tbh vultures 1 clears both🦅", username: "qwertyyy")
                            
                            Spacer(minLength: 8)
                        }
                        
                        HStack(alignment: .bottom, spacing: 8) {
                            VStack {
                                Capsule()
                                    .fill(strokeColor)
                                    .frame(width: 4)
                                
                                AvatarView(size: 40, imageURL: "https://i.pinimg.com/474x/ca/a6/c7/caa6c70c24e6705894a36755fdba4fca.jpg")
                            }
                            .frame(maxHeight: .infinity)
                            
                            ReplyBubble(text: "in what world lmao", username: "august", color: strokeColor)
                            
                            Spacer(minLength: 8)
                        }
                        .frame(maxHeight: .infinity) // Important!
                    }
                    
                    /// Third Reply
                    VStack(spacing: 8) {
                        // Parent
                        HStack(alignment: .bottom, spacing: 8) {
                            VStack {
                                Capsule()
                                    .fill(strokeColor)
                                    .frame(width: 4, height: 8)
                                
                                LoopPath()
                                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 32, height: 24)
                                
                                AvatarView(size: 24, imageURL: "https://i.pinimg.com/736x/c9/00/97/c90097f2cca68e76fc40831ba96dc9a5.jpg")
                                    .frame(width: 40)
                            }
                            .frame(maxHeight: .infinity)
                            
                            ReplyOutlineBubble(text: "don’t piss me off WLR was the blueprint", username: "lancey_fouxx")
                            
                            Spacer(minLength: 8)
                        }
                        
                        HStack(alignment: .bottom, spacing: 8) {
                            VStack {
                                Capsule()
                                    .fill(strokeColor)
                                    .frame(width: 4)
                                
                                AvatarView(size: 40, imageURL: "https://i.pinimg.com/474x/fd/f1/21/fdf12119ecb977a68bc10d185dbb2523.jpg")
                            }
                            .frame(maxHeight: .infinity)
                            
                            ReplyBubble(text: "Im a fan of both but wlr is wayyyyyyyy better, my fav album", username: "zack+", color: strokeColor)
                            
                            Spacer(minLength: 8)
                        }
                        .frame(maxHeight: .infinity) // Important!
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, safeAreaInsets.bottom)
                
            }
            .defaultScrollAnchor(.bottom)
        }
        .overlay(alignment: .top) {
            Image(systemName: "chevron.down")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(strokeColor)
        }
        // after appear
        .onAppear {
            withAnimation(.smooth(duration: 0.7)) {
                didAppear = true
            }
        }
    }
}

struct ReplyBubble: View {
    let text: String
    let username: String
    var artist: String?
    var album: String?
    let color: Color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color, in: WispBubbleWithTail(scale: 1))
            .clipShape(WispBubbleWithTail(scale: 1))
            .foregroundStyle(.secondary)
            .padding(.bottom, 3)
            .overlay(alignment: .topLeading) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(username)
                        .foregroundColor(.secondary)
                        .font(.system(size: 11, weight: .regular))

                    if let artist = artist, let album = album {
                        Text("·")
                            .foregroundColor(.secondary)
                            .font(.system(size: 11, weight: .bold))

                        VStack(alignment: .leading) {
                            Text("\(artist), \(album)")
                                .foregroundColor(.secondary)
                                .font(.system(size: 11, weight: .semibold))
                                .lineLimit(1)
                        }
                    }
                }
                .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }

            BlipView(size: CGSize(width: 60, height: 60), fill: color)
                .alignmentGuide(VerticalAlignment.top) { d in d.height / 1.5 }
                .alignmentGuide(HorizontalAlignment.trailing) { d in d.width * 1.0 }
                .offset(x: 20, y: 0)
        }
    }
}

struct ReplyOutlineBubble: View {
    let text: String
    let username: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(text)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                WispBubbleWithTail(scale: 1)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                Text(username)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                    .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 6)
        }
    }
}

class Preview: Identifiable, Equatable {
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

    static func == (lhs: Preview, rhs: Preview) -> Bool {
        return lhs.id == rhs.id
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
