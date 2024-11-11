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

    @Namespace var animation
    @State private var showSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0 ..< min(6, biome.entities.count), id: \.self) { index in
                let entity = biome.entities[index]
                let isRoot = entity.parent == nil
                let previousEntity = index > 0 ? biome.entities[index - 1] : nil

                EntityView(rootEntity: biome.entities[0], previousEntity: previousEntity, entity: entity, isRoot: isRoot, color: color, secondaryColor: secondaryColor)
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
            BiomeExpandedView(biome: Biome(entities: biomeOneExpanded))
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
        created_at: Date(timeIntervalSinceNow: -3600),
        attachments: [
            SongAttachment(id: "idk",
                           artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/18/62/27/18622713-a797-9f9d-b85c-f0373f190a27/075679634382.jpg/632x632bb.webp",
                           name: "Eusexua",
                           artistName: "FKA Twigs")
        ]
    )

    return [
        parentEntity,
        Entity(
            id: "4",
            username: "vjeranski",
            avatar: "https://d2w9rnfcy7mm78.cloudfront.net/31132288/original_b3573ce965ab3459b25ab0977beec40b.jpg",
            text: "delusional",
            created_at: Date(timeIntervalSinceNow: -1200),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif",
                text: "No and tbh vultures 1 clears both🦅",
                created_at: Date(timeIntervalSinceNow: -2400),
                attachments: [
                    SongAttachment(id: "idk",
                                   artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/25/47/fa/2547fae8-2010-7b31-8dc7-1a93de4a3269/cover.jpg/632x632bb.webp",
                                   name: "Vultures 1",
                                   artistName: "Kanye West")
                ]
            )
        ),
        Entity(
            id: "5",
            username: "zack+",
            avatar: "https://i.pinimg.com/474x/fd/f1/21/fdf12119ecb977a68bc10d185dbb2523.jpg",
            text: "Do not piss me off rn WLR was the template.",
            created_at: Date(timeIntervalSinceNow: -600),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif",
                text: "No and tbh vultures 1 clears both🦅",
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        )
    ]
}()

let biomeTwo: [Entity] = {
    let parentEntity = Entity(
        id: "0",
        username: "neonDream",
        avatar: "https://i.pinimg.com/474x/5a/4c/73/5a4c73cb4ea137d5b52d7a3c1459c42a.jpg",
        text: "This installation is insane. Feels like walking inside a memory you can’t quite remember. Wild stuff.",
        created_at: Date(timeIntervalSinceNow: -3600),
        attachments: [
            SongAttachment(id: "exhibit2024",
                           artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/02/1d/30/021d3036-5503-3ed3-df00-882f2833a6ae/17UM1IM17026.rgb.jpg/632x632bb.webp",
                           name: "dont smile at me",
                           artistName: "Billie Eilish")
        ]
    )

    return [
        parentEntity,
        Entity(
            id: "2",
            username: "synesthesia",
            avatar: "https://i.pinimg.com/474x/16/a2/5d/16a25d5a1db5b04f4cf1f519d8070c07.jpg",
            text: "I get that, but if you stick around, it starts pulling you in. It’s almost hypnotic, like it’s pulling memories out of your head.",
            created_at: Date(timeIntervalSinceNow: -2800),
            parent: parentEntity
        ),
        Entity(
            id: "3",
            username: "echoVerse",
            avatar: "https://i.pinimg.com/474x/9b/3c/11/9b3c11429ec2b25b0135566ad3e6c482.jpg",
            text: "Alright, maybe I’ll give it another shot. I guess I was expecting something less… polished.",
            created_at: Date(timeIntervalSinceNow: -2400), 
            parent: Entity(id: "1", username: "echoVerse", avatar: "", text: "", created_at: Date())
        )
    ]
}()

let biomeOneExpanded: [Entity] = {
    let parentEntity = Entity(
        id: "0",
        username: "autobahn",
        avatar: "https://i.pinimg.com/474x/9f/38/61/9f38614bb1acaad50e1959f4e3d5768c.jpg",
        text: "yall are insane. this is peak, sounds like autolux. also, its not like theyre hiding the fact that they took inspiration",
        created_at: Date(timeIntervalSinceNow: -3600),
        attachments: [
            SongAttachment(id: "idk",
                           artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/18/62/27/18622713-a797-9f9d-b85c-f0373f190a27/075679634382.jpg/632x632bb.webp",
                           name: "Eusexua",
                           artistName: "FKA Twigs")
        ]
    )

    return [
        parentEntity,
        Entity(
            id: "1",
            username: "qwertyyy",
            avatar: "qwertyyy",
            text: "No and tbh vultures 1 clears both🦅",
            created_at: Date(timeIntervalSinceNow: -2400),
            parent: parentEntity
        ),
        Entity(
            id: "2",
            username: "vjeranski",
            avatar: "vjeranski",
            text: "i see it",
            created_at: Date(timeIntervalSinceNow: -1700),
            parent: parentEntity,
            attachments: [
                SongAttachment(id: "idk",
                               artwork: "https://is1-ssl.mzstatic.com/image/thumb/Video211/v4/93/01/d3/9301d31b-3c90-8f26-44c9-a403c186cbac/Job70a1c5af-b67a-4cf3-a2d6-dc032483f151-169441773-PreviewImage_Preview_Image_Intermediate_nonvideo_sdr_329793320_1793175885-Time1717534608063.png/632x632bb.webp",
                               name: "Sympathy is a knife",
                               artistName: "Charli XCX")
            ]
        ),
        Entity(
            id: "3",
            username: "starrry",
            avatar: "starrry",
            text: "is the autolux in the room with us",
            created_at: Date(timeIntervalSinceNow: -1800),
            parent: parentEntity
        ),
        Entity(
            id: "4",
            username: "vjeranski",
            avatar: "vjeranski",
            text: "delusional",
           
            created_at: Date(timeIntervalSinceNow: -1200),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "5",
            username: "zack+",
            avatar: "zack+",
            text: "Do not piss me off rn WLR was the template.",
           
            created_at: Date(timeIntervalSinceNow: -600),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
               
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "7",
            username: "gravity_falls",
            avatar: "gravity_falls",
            text: "WLR got you guys acting like it’s the blueprint for everything 😂",
           
            created_at: Date(timeIntervalSinceNow: -1100),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
               
                created_at: Date(timeIntervalSinceNow: -600)
            )
        ),
        Entity(
            id: "6",
            username: "futurevibes",
            avatar: "futurevibes",
            text: "autolux would never lol",
           
            created_at: Date(timeIntervalSinceNow: -1500),
            parent: parentEntity
        ),
        Entity(
            id: "8",
            username: "emily_rose",
            avatar: "emily_rose",
            text: "Hit Me Hard and Soft on repeat… they knew exactly what they were doing",
           
            created_at: Date(timeIntervalSinceNow: -950),
            parent: parentEntity
        ),
        Entity(
            id: "9",
            username: "ghostride",
            avatar: "ghostride",
            text: "wont lie tho, vultures 1 was vibes",
           
            created_at: Date(timeIntervalSinceNow: -900),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
               
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "10",
            username: "midas",
            avatar: "midas",
            text: "i see the influence but not a copy at all",
           
            created_at: Date(timeIntervalSinceNow: -820),
            parent: parentEntity
        ),
        Entity(
            id: "11",
            username: "emily_rose",
            avatar: "emily_rose",
            text: "how are people comparing this to WLR anyway?",
           
            created_at: Date(timeIntervalSinceNow: -750),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
               
                created_at: Date(timeIntervalSinceNow: -600)
            )
        ),
        Entity(
            id: "12",
            username: "digitaldr3am",
            avatar: "digitaldr3am",
            text: "some ppl just have to hate it’s sad fr",
           
            created_at: Date(timeIntervalSinceNow: -600),
            parent: parentEntity
        ),
        Entity(
            id: "13",
            username: "starrry",
            avatar: "starrry",
            text: "WLR set the bar but y’all act like no one else can have range",
           
            created_at: Date(timeIntervalSinceNow: -500),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
               
                created_at: Date(timeIntervalSinceNow: -600)
            )
        ),
        Entity(
            id: "14",
            username: "soundwaver",
            avatar: "soundwaver",
            text: "true artists always take inspiration and elevate it",
           
            created_at: Date(timeIntervalSinceNow: -400),
            parent: parentEntity
        ),
        Entity(
            id: "15",
            username: "aurora.lights",
            avatar: "aurora.lights",
            text: "first time hearing it and honestly got chills",
           
            created_at: Date(timeIntervalSinceNow: -360),
            parent: parentEntity
        ),
        Entity(
            id: "16",
            username: "dreamcatcher",
            avatar: "dreamcatcher",
            text: "this album cover is so fitting too",
           
            created_at: Date(timeIntervalSinceNow: -340),
            parent: parentEntity
        ),
        Entity(
            id: "17",
            username: "futurevibes",
            avatar: "futurevibes",
            text: "been on my playlist since day one",
           
            created_at: Date(timeIntervalSinceNow: -300),
            parent: parentEntity
        ),
        Entity(
            id: "18",
            username: "noir_paws",
            avatar: "noir_paws",
            text: "I get what autobahn means though, it has that familiar sound",
           
            created_at: Date(timeIntervalSinceNow: -250),
            parent: parentEntity
        ),
        Entity(
            id: "19",
            username: "thursday_born",
            avatar: "thursday_born",
            text: "Vultures 1 has a vibe but this is on another level",
           
            created_at: Date(timeIntervalSinceNow: -200),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "qwertyyy",
                text: "No and tbh vultures 1 clears both🦅",
                created_at: Date(timeIntervalSinceNow: -2400)
            )
        ),
        Entity(
            id: "20",
            username: "nebula_eyez",
            avatar: "nebula_eyez",
            text: "autolux, billie, vibes collab when?",
           
            created_at: Date(timeIntervalSinceNow: -180),
            parent: parentEntity
        ),
        Entity(
            id: "21",
            username: "midas",
            avatar: "midas",
            text: "fr tho ppl will find anything to hate on",
           
            created_at: Date(timeIntervalSinceNow: -150),
            parent: Entity(
                id: "5",
                username: "zack+",
                avatar: "zack+",
                text: "Do not piss me off rn WLR was the template.",
               
                created_at: Date(timeIntervalSinceNow: -600)
            )
        )
    ]
}()
