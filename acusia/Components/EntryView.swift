//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

struct Line: Shape {
    var x2: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: x2, y: rect.height))
        return path
    }
}

struct EntryView: View {
    @EnvironmentObject private var windowState: WindowState

    let entrySet: EntrySet
    let strokeColor = Color(UIColor.systemGray5)

    @Namespace var animation
    @State private var selected: EntryModel?

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let artwork = entrySet.entries.first?.artwork {
                /// Only render if the entry is a root
                AsyncImage(url: URL(string: artwork)) { image in
                    image
                        .resizable()
                } placeholder: {
                    Rectangle()
                }
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .padding(2)
                .frame(width: 160, height: 160)
            }

            VStack(spacing: 8) {
                /// Loop through up to 6 entries.
                ForEach(0 ..< min(6, entrySet.entries.count), id: \.self) { index in
                    let entry = entrySet.entries[index]
                    let isRoot = entry.parent == nil
                    let previousEntry = index > 0 ? entrySet.entries[index - 1] : nil

                    VStack(spacing: 8) {
                        /// Contextual Parent Logic
                        /// Render context if:
                        /// - This entry has a parent (this entry is not the root).
                        /// - The previous entry's parent is not the same as this entry.
                        /// - The parent is not the previous entry.
                        if let parent = entry.parent, previousEntry?.parent?.id != parent.id, previousEntry?.id != parent.id {
                            VStack(alignment: .leading) {
                                Capsule()
                                    .fill(strokeColor)
                                    .frame(width: 4, height: 8)
                                    .frame(width: 40)

                                HStack(spacing: 12) {
                                    LoopPath()
                                        .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .frame(width: 40, height: 32)
                                        .scaleEffect(x: -1, y: 1)

                                    AvatarView(size: 24, imageURL: parent.avatar)

                                    EntryBubbleOutlined(entry: parent)
                                        .padding(.leading, -4)
                                }
                            }
                        }

                        /// Entry Rendering
                        HStack(alignment: .bottom, spacing: 8) {
                            VStack {
                                if !isRoot {
                                    Rectangle()
                                        .strokeBorder(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [4, 12]))
                                        .frame(width: 4)
                                } else {
                                    Spacer()
                                }

                                AvatarView(size: 40, imageURL: entry.avatar)
                                    .overlay(alignment: .topLeading) {
                                        if isRoot {
                                            /// Only render if the entry is a root
                                            ZStack {
                                                AsyncImage(url: URL(string: entry.artwork ?? "")) { image in
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
                                    }
                            }
                            .frame(width: 40)
                            .frame(maxHeight: .infinity)

                            EntryBubble(entry: entry, color: strokeColor)
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(
                .thickMaterial,
                in: RoundedRectangle(cornerRadius: 45, style: .continuous)
            )
            .foregroundStyle(.secondary)
            .matchedTransitionSource(id: entrySet.entries.first?.id ?? "", in: animation)
            .sheet(item: $selected) { entry in
                DetailView(entry: entry)
                    .navigationTransition(.zoom(sourceID: entry.id, in: animation))
                    .presentationBackground(.black)
            }
        }
        .padding(.horizontal, 24)
        .onTapGesture {
            selected = entrySet.entries.first
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
                    // Chrono
                }
                .padding(.horizontal, 24)
                .padding(.bottom, safeAreaInsets.bottom)
            }
            .defaultScrollAnchor(.bottom)
        }
        .overlay(alignment: .top) {
            Image(systemName: "chevron.down")
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(strokeColor)
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.7)) {
                didAppear = true
            }
        }
    }
}

let entriesOne: [EntryModel] = {
    let parentEntry = EntryModel(
        id: "0",
        username: "autobahn",
        avatar: "https://i.pinimg.com/474x/9f/38/61/9f38614bb1acaad50e1959f4e3d5768c.jpg",
        text: "yall are insane. this is peak, sounds like autolux. also, its not like theyre hiding the fact that they took inspiration",
        rating: 2,
        artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/49/8a/34/498a34eb-27af-4f6f-5e42-d6863b37e05d/24UM1IM01096.rgb.jpg/632x632bb.webp",
        name: "Lyfestyle",
        artistName: "Yeat",
        created_at: Date(timeIntervalSinceNow: -3600)
    )

    return [
        parentEntry,
        EntryModel(
            id: "3",
            username: "starrry",
            avatar: "https://i.pinimg.com/474x/d8/5d/02/d85d022bedcf129ebd23a2b21e97ef19.jpg",
            text: "this is a test",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1800),
            parent: parentEntry
        ),
        EntryModel(
            id: "2",
            username: "vjeranski",
            avatar: "https://i.pinimg.com/474x/ca/a6/c7/caa6c70c24e6705894a36755fdba4fca.jpg",
            text: "i see it",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1700),
            parent: parentEntry
        ),
        EntryModel(
            id: "4",
            username: "vjeranski",
            avatar: "https://d2w9rnfcy7mm78.cloudfront.net/31132288/original_b3573ce965ab3459b25ab0977beec40b.jpg",
            text: "delusional",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1200),
            parent: EntryModel(
                id: "1",
                username: "qwertyyy",
                avatar: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif",
                text: "No and tbh vultures 1 clears both🦅",
                rating: 2,
                artwork: nil,
                name: nil,
                artistName: nil,
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        EntryModel(
            id: "5",
            username: "zack+",
            avatar: "https://i.pinimg.com/474x/fd/f1/21/fdf12119ecb977a68bc10d185dbb2523.jpg",
            text: "Do not piss me off rn WLR was the template",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -600),
            parent: EntryModel(
                id: "1",
                username: "qwertyyy",
                avatar: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif",
                text: "No and tbh vultures 1 clears both🦅",
                rating: 2,
                artwork: nil,
                name: nil,
                artistName: nil,
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        )
    ]
}()

let entrySet = EntrySet(entries: entriesOne)

let sampleEntrySets = [
    entrySet
]

class EntryModel: Equatable, Identifiable {
    let id: String
    let username: String
    let avatar: String
    let text: String
    let rating: Int
    let artwork: String?
    let name: String?
    let artistName: String?
    let created_at: Date
    let parent: EntryModel?

    init(id: String,
         username: String,
         avatar: String,
         text: String,
         rating: Int,
         artwork: String? = nil,
         name: String? = nil,
         artistName: String? = nil,
         created_at: Date,
         parent: EntryModel? = nil)
    {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.text = text
        self.rating = rating
        self.artwork = artwork
        self.name = name
        self.artistName = artistName
        self.created_at = created_at
        self.parent = parent
    }

    static func == (lhs: EntryModel, rhs: EntryModel) -> Bool {
        lhs.id == rhs.id &&
            lhs.username == rhs.username &&
            lhs.avatar == rhs.avatar &&
            lhs.text == rhs.text &&
            lhs.rating == rhs.rating &&
            lhs.artwork == rhs.artwork &&
            lhs.name == rhs.name &&
            lhs.artistName == rhs.artistName &&
            lhs.parent?.id == rhs.parent?.id
            && lhs.created_at == rhs.created_at
    }
}

struct EntrySet: Identifiable {
    let id = UUID()
    private(set) var entries: [EntryModel]

    init(entries: [EntryModel]) {
        precondition(entries.count <= 8, "EntrySet can hold up to 8 entries.")
        self.entries = entries
    }
}
