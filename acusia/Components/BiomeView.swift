//
//  BiomeView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

struct BiomeView: View {
    @EnvironmentObject private var windowState: WindowState

    let biome: Biome
    let color = Color(UIColor.systemGray5)
    let secondaryColor = Color(UIColor.systemGray4)

    let expandedBiomes: [Biome] = [
        Biome(entities: biomeOneExpanded)
    ]

    @Namespace var animation
    @State private var showSheet: Bool = false

    var body: some View {
        /// Loop through up to 6 entries.
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0 ..< min(6, biome.entities.count), id: \.self) { index in
                let entity = biome.entities[index]
                let isRoot = entity.parent == nil
                let previousEntity = index > 0 ? biome.entities[index - 1] : nil
                
                EntityView(root: biome.entities[0], previousEntity: previousEntity, entity: entity, isRoot: isRoot, color: color, secondaryColor: secondaryColor)
                    .frame(maxHeight: .infinity)
                    .shadow(
                        color: isRoot ? .black.opacity(0.15) : .clear,
                        radius: isRoot ? 12 : 0,
                        x: 0,
                        y: isRoot ? 4 : 0
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            .thickMaterial,
            in: RoundedRectangle(cornerRadius: 40, style: .continuous)
        )
        .foregroundStyle(.secondary)
        .matchedTransitionSource(id: biome.entities.first?.id ?? "", in: animation)
        .sheet(isPresented: $showSheet) {
            BiomeExpandedView(biome: expandedBiomes[0])
                .navigationTransition(.zoom(sourceID: biome.entities.first?.id ?? "", in: animation))
                .presentationBackground(.black)
        }
        .padding(.horizontal, 24)
        .onTapGesture {
            showSheet = true
        }
    }
}

let biomeOne: [Entity] = {
    let parentEntity = Entity(
        id: "0",
        username: "autobahn",
        avatar: "https://i.pinimg.com/474x/9f/38/61/9f38614bb1acaad50e1959f4e3d5768c.jpg",
        text: "yall are insane. this is peak, sounds like autolux. also, its not like theyre hiding the fact that they took inspiration",
        rating: 2,
        artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/18/62/27/18622713-a797-9f9d-b85c-f0373f190a27/075679634382.jpg/632x632bb.webp",
        name: "Eusexua",
        artistName: "FKA Twigs",
        created_at: Date(timeIntervalSinceNow: -3600)
    )

    return [
        parentEntity,
        Entity(
            id: "3",
            username: "starrry",
            avatar: "https://i.pinimg.com/474x/d8/5d/02/d85d022bedcf129ebd23a2b21e97ef19.jpg",
            text: "is the autolux in the room with us",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1800),
            parent: parentEntity
        ),
        Entity(
            id: "4",
            username: "vjeranski",
            avatar: "https://d2w9rnfcy7mm78.cloudfront.net/31132288/original_b3573ce965ab3459b25ab0977beec40b.jpg",
            text: "delusional",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1200),
            parent: Entity(
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
        Entity(
            id: "5",
            username: "zack+",
            avatar: "https://i.pinimg.com/474x/fd/f1/21/fdf12119ecb977a68bc10d185dbb2523.jpg",
            text: "Do not piss me off rn WLR was the template.",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -600),
            parent: Entity(
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

let biomeOneExpanded: [Entity] = {
    let parentEntity = Entity(
        id: "0",
        username: "autobahn",
        avatar: "https://i.pinimg.com/474x/9f/38/61/9f38614bb1acaad50e1959f4e3d5768c.jpg",
        text: "yall are insane. this is peak, sounds like autolux. also, its not like theyre hiding the fact that they took inspiration",
        rating: 2,
        artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/18/62/27/18622713-a797-9f9d-b85c-f0373f190a27/075679634382.jpg/632x632bb.webp",
        name: "Eusexua",
        artistName: "FKA Twigs",
        created_at: Date(timeIntervalSinceNow: -3600)
    )

    return [
        parentEntity,
        Entity(
            id: "1",
            username: "qwertyyy",
            avatar: "qwertyyy",
            text: "No and tbh vultures 1 clears both🦅",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -2400),
            parent: parentEntity
        ),
        Entity(
            id: "2",
            username: "vjeranski",
            avatar: "vjeranski",
            text: "i see it",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1700),
            parent: parentEntity
        ),
        Entity(
            id: "3",
            username: "starrry",
            avatar: "starrry",
            text: "is the autolux in the room with us",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1800),
            parent: parentEntity
        ),
        Entity(
            id: "4",
            username: "vjeranski",
            avatar: "vjeranski",
            text: "delusional",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1200),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "5",
            username: "zack+",
            avatar: "zack+",
            text: "Do not piss me off rn WLR was the template.",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -600),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "6",
            username: "futurevibes",
            avatar: "futurevibes",
            text: "autolux would never lol",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1500),
            parent: parentEntity
        ),
        Entity(
            id: "7",
            username: "gravity_falls",
            avatar: "gravity_falls",
            text: "WLR got you guys acting like it’s the blueprint for everything 😂",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -1100),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -600)
            )
        ),
        Entity(
            id: "8",
            username: "emily_rose",
            avatar: "emily_rose",
            text: "Hit Me Hard and Soft on repeat… they knew exactly what they were doing",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -950),
            parent: parentEntity
        ),
        Entity(
            id: "9",
            username: "ghostride",
            avatar: "ghostride",
            text: "wont lie tho, vultures 1 was vibes",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -900),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "10",
            username: "midas",
            avatar: "midas",
            text: "i see the influence but not a copy at all",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -820),
            parent: parentEntity
        ),
        Entity(
            id: "11",
            username: "emily_rose",
            avatar: "emily_rose",
            text: "how are people comparing this to WLR anyway?",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -750),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -600)
            )
        ),
        Entity(
            id: "12",
            username: "digitaldr3am",
            avatar: "digitaldr3am",
            text: "some ppl just have to hate it’s sad fr",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -600),
            parent: parentEntity
        ),
        Entity(
            id: "13",
            username: "starrry",
            avatar: "starrry",
            text: "WLR set the bar but y’all act like no one else can have range",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -500),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -600)
            )
        ),
        Entity(
            id: "14",
            username: "soundwaver",
            avatar: "soundwaver",
            text: "true artists always take inspiration and elevate it",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -400),
            parent: parentEntity
        ),
        Entity(
            id: "15",
            username: "aurora.lights",
            avatar: "aurora.lights",
            text: "first time hearing it and honestly got chills",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -360),
            parent: parentEntity
        ),
        Entity(
            id: "16",
            username: "dreamcatcher",
            avatar: "dreamcatcher",
            text: "this album cover is so fitting too",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -340),
            parent: parentEntity
        ),
        Entity(
            id: "17",
            username: "futurevibes",
            avatar: "futurevibes",
            text: "been on my playlist since day one",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -300),
            parent: parentEntity
        ),
        Entity(
            id: "18",
            username: "noir_paws",
            avatar: "noir_paws",
            text: "I get what autobahn means though, it has that familiar sound",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -250),
            parent: parentEntity
        ),
        Entity(
            id: "19",
            username: "thursday_born",
            avatar: "thursday_born",
            text: "Vultures 1 has a vibe but this is on another level",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -200),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "20",
            username: "nebula_eyez",
            avatar: "nebula_eyez",
            text: "autolux, billie, vibes collab when?",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -180),
            parent: parentEntity
        ),
        Entity(
            id: "21",
            username: "midas",
            avatar: "midas",
            text: "fr tho ppl will find anything to hate on",
            rating: 2,
            created_at: Date(timeIntervalSinceNow: -150),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
                rating: 2,
                created_at: Date(timeIntervalSinceNow: -600)
            )
        )
    ]
}()

let biomes = [
    Biome(entities: biomeOne)
]

class Entity: Equatable, Identifiable {
    let id: String
    let username: String
    let avatar: String
    let text: String
    let rating: Int
    let artwork: String?
    let name: String?
    let artistName: String?
    let created_at: Date
    let parent: Entity?

    init(id: String,
         username: String,
         avatar: String,
         text: String,
         rating: Int,
         artwork: String? = nil,
         name: String? = nil,
         artistName: String? = nil,
         created_at: Date,
         parent: Entity? = nil)
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

    static func == (lhs: Entity, rhs: Entity) -> Bool {
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

struct Biome: Identifiable {
    let id = UUID()
    private(set) var entities: [Entity]

    init(entities: [Entity]) {
        self.entities = entities
    }
}
