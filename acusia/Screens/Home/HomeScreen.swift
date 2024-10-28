import SwiftUI

class HomeState: ObservableObject {
    // Singleton instance
    static let shared = HomeState()

    // Prevent external initialization
    init() {}

    // Your shared properties go here
    @Published var isExpanded: Bool = false

    // ScrollView Properties
    @Published var mainScrollValue: CGFloat = 0
    @Published var topScrollViewValue: CGFloat = 0

    // These properties will be used to evaluate the drag conditions,
    // whether the scroll view can either be pulled up or down for expanding/minimizing the photos scrollview
    @Published var canPullDown: Bool = false
    @Published var canPullUp: Bool = false

    @Published var gestureProgress: CGFloat = 0

    @Published var showReplies: Bool = false
    @Published var repliesOffset: CGFloat = 0
}

struct Home: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var shareData: HomeState

    @State private var tappedEntry: EntryModel?
    @State private var tappedPosition: CGPoint = .zero
    @State private var tappedSize: CGSize = .zero

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                /// User's Past?
                // PastView(size: size)

                /// Main Feed
                LazyVStack(spacing: 64) {
                    ForEach(entries) { entry in
                        ZStack {
                            WispView(entry: entry)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.black.onTapGesture {
                                    if tappedEntry != nil {
                                        withAnimation(.smooth) {
                                            tappedEntry = nil
                                        }
                                    } else {
                                        withAnimation(.smooth) {
                                            tappedEntry = (tappedEntry == entry) ? nil : entry
                                        }
                                        tappedPosition = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY)
                                        tappedSize = geometry.size
                                    }
                                }
                            })
                        .scaleEffect(tappedEntry != nil && tappedEntry != entry ? 0.96 : 1)
                        .animation(.interactiveSpring(duration: 0.4, extraBounce: 0.5), value: tappedEntry)
                    }
                }
                .padding(.top, safeAreaInsets.top)
            }
        }
        .scrollClipDisabled(true)
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.y
        } action: { _, newValue in
            if newValue > windowState.size.height {
                windowState.symmetryState = .feed
            } else {
                windowState.symmetryState = .collapsed
            }
        }
        .frame(width: windowState.size.width, height: windowState.size.height)
        .overlay(
            ZStack {
                if tappedEntry != nil {
                    RadialVariableBlurView(radius: 4, position: tappedPosition, size: tappedSize)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    RadialGradientMask(center: tappedPosition, size: tappedSize)
                }
            }
            .allowsHitTesting(false)
        )
        .overlay(alignment: .top) {
            VStack {
                VariableBlurView(radius: 1, mask: Image(.gradient))
                    .scaleEffect(x: 1, y: -1)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top * 1.5)
                Spacer()
            }
        }
    }
}

struct EntryModel: Equatable, Identifiable {
    let id = UUID()
    let username: String
    let userImage: String
    let imageUrl: String
    let name: String
    let artistName: String
    let text: String
    let rating: Int
}

let entries: [EntryModel] = [
    EntryModel(
        username: "autobahn",
        userImage: "https://i.pinimg.com/474x/9f/38/61/9f38614bb1acaad50e1959f4e3d5768c.jpg",
        imageUrl: "https://e.snmc.io/i/600/w/f4af27ec1e80ff187db7e9e8313cfad0/12297609/julie-my-anti-aircraft-friend-Cover-Art.jpg",
        name: "my anti-aircraft friend",
        artistName: "julie",
        text: "yall are insane. this is peak, sounds like the best of autolux",
        rating: 2
    ),
    EntryModel(
        username: "starrry",
        userImage: "https://i.pinimg.com/474x/d8/5d/02/d85d022bedcf129ebd23a2b21e97ef19.jpg",
        imageUrl: "https://e.snmc.io/i/600/w/d236196c04741650000aea22a62f5363/12229480/coldplay-moon-music-Cover-Art.jpg",
        name: "Moon Music",
        artistName: "Coldplay",
        text: "The first impression is that there's one decent song, which was the first single, and the rest is all filler, b side material. ",
        rating: 2
    ),
    EntryModel(
        username: "indie_fan",
        userImage: "https://i.pinimg.com/474x/fb/d1/a7/fbd1a7f6066b1c94da2cf5ffdd9dba3d.jpg",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/d3/79/bd/d379bd8a-3d54-eaa5-3c6b-775e62924496/196872431667.jpg/632x632bb.webp",
        name: "The Great Impersonator",
        artistName: "Halsey",
        text: "i can confidently say it is one of the best concept albums i've ever listened to",
        rating: 0
    ),
    EntryModel(
        username: "florence_fanatic",
        userImage: "https://i.pinimg.com/474x/43/07/28/430728c5b11e576df3e85652a96b7afb.jpg",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Video126/v4/a1/0d/9d/a10d9dc0-e899-4bc0-4dcb-445dd935bb8d/Jobda11268e-c93f-4983-89ba-382710db07b6-153000381-PreviewImage_preview_image_nonvideo_sdr-Time1689709715173.png/632x632bb.webp",
        name: "Playing Robots Into Heaven",
        artistName: "James Blake",
        text: "WALL-E got dumped, listened to Bon Iver and wrote an album in the woods like his hero.",
        rating: 3
    ),
    EntryModel(
        username: "florence_fanatic",
        userImage: "https://i.pinimg.com/474x/43/07/28/430728c5b11e576df3e85652a96b7afb.jpg",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/bd/f6/83/bdf683a5-28de-08cb-cb91-2940c1e6270b/196871853729.jpg/1000x1000bb.jpg",
        name: "Cowboy Carter",
        artistName: "Beyonce",
        text: "Florence is a queen. I can go on and on about what she means to me but I won’t",
        rating: 0
    ),
    EntryModel(
        username: "bey",
        userImage: "https://wallpapers.com/images/hd/oscar-zahn-skeleton-headphones-unique-cool-pfp-rboah21ctf7m37o0.jpg",
        imageUrl: "https://i.scdn.co/image/ab67616d0000b2736c7112082b63beefffe40151",
        name: "Kid A",
        artistName: "Radiohead",
        text: "This album is closest a band can get to perfection. Abstract yet poignant, Kid A is an album filled with contradiction fusing elements of acid, rock, folk, trance and house together to create a truly experimental and epic album.",
        rating: 0
    ),
    EntryModel(
        username: "bey",
        userImage: "https://wallpapers.com/images/hd/oscar-zahn-skeleton-headphones-unique-cool-pfp-rboah21ctf7m37o0.jpg",
        imageUrl: "https://i.scdn.co/image/ab67616d0000b2736c7112082b63beefffe40151",
        name: "Kid A",
        artistName: "Radiohead",
        text: "This album is closest a band can get to perfection. Abstract yet poignant, Kid A is an album filled with contradiction fusing elements of acid, rock, folk, trance and house together to create a truly experimental and epic album.",
        rating: 3
    )
]
