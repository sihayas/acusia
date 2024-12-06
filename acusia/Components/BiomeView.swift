//
//  BiomeView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

struct BiomeView: View {
    @EnvironmentObject private var windowState: UIState

    let biome: Biome

    @Namespace var animation
    @State private var showSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0 ..< biome.entities.count, id: \.self) { index in
                    let previousEntity = index > 0 ? biome.entities[index - 1] : nil
                    
                    EntityView(rootEntity: biome.entities[0],
                               previousEntity: previousEntity,
                               entity: biome.entities[index],
                               isExpandedView: false
                    )
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(24)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .foregroundStyle(.secondary)
            .matchedTransitionSource(id: "hi", in: animation)
            .sheet(isPresented: $showSheet) {
                BiomeExpandedView(biome: Biome(entities: biomeOneExpanded))
                    .navigationTransition(.zoom(sourceID: "hi", in: animation))
                    .presentationBackground(.black)
            }
            .padding(.horizontal, 12)
            .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 8)
            .onTapGesture {
                showSheet = true
            }
            
            HStack(spacing: 16) {
                CollageLayout {
                    ForEach(userDevs.prefix(5), id: \.id) { user in
                        Circle()
                            .background(
                                AsyncImage(url: URL(string: user.imageUrl)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                            )
                            .foregroundStyle(.clear)
                            .clipShape(Circle())
                    }
                }
                .frame(width: 52, height: 52)
                    
                VStack(alignment: .leading, spacing: 4) {
                    Text("gods weakest soldiers")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text("21")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        // .background(.blue, in: Capsule())
                        
                        HStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text("786")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        // .background(.ultraThinMaterial, in: Capsule())
                        
                        HStack(spacing: 4) {
                            Image(systemName: "ellipsis.message.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text("7")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        // .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 48)
        }
    }
}

struct UserDev: Identifiable {
    let id: String
    let alias: String
    let imageUrl: String
}

let userDevs = [
    UserDev(id: UUID().uuidString, alias: "coldhealing", imageUrl: "https://pbs.twimg.com/profile_images/1759706838319161344/QZE066Lr_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "apple.user7456", imageUrl: "https://pbs.twimg.com/profile_images/1828581255069241344/QySOaDzU_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "jxnlco", imageUrl: "https://pbs.twimg.com/profile_images/1855940230362103808/_8fGXfK6_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "yieldcurved", imageUrl: "https://pbs.twimg.com/profile_images/1562843260304863232/s_Cv2vdy_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "quiet.frame", imageUrl: "https://pbs.twimg.com/profile_images/1709499954711142400/sHmbME_7_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "lunarsocket", imageUrl: "https://i.pinimg.com/474x/72/ca/b5/72cab57cce1ac8e7c1141078ff05c141.jpg"),
    UserDev(id: UUID().uuidString, alias: "velvetdrive", imageUrl: "https://pbs.twimg.com/profile_images/1805385770192322566/dinq0ojH_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "sliptrails", imageUrl: "https://i.pinimg.com/280x280_RS/46/2c/23/462c230588dcb4884c65f5eae3f39dc3.jpg"),
    UserDev(id: UUID().uuidString, alias: "softflares", imageUrl: "https://i.pinimg.com/280x280_RS/07/24/97/0724977eb9e1b0154bb3a5d6d82e0b33.jpg"),
    UserDev(id: UUID().uuidString, alias: "cozy.plan", imageUrl: "https://i.pinimg.com/280x280_RS/5a/c7/da/5ac7dabeb65f63e25950ca54fae03393.jpg"),
    UserDev(id: UUID().uuidString, alias: "winter.signal", imageUrl: "https://i.pinimg.com/280x280_RS/6a/08/16/6a081649460fa6f2ca716079c824b5b6.jpg"),
    UserDev(id: UUID().uuidString, alias: "sequoia.trace", imageUrl: "https://i.pinimg.com/280x280_RS/83/11/fb/8311fb2afaeb6dd10dab81886cc603ac.jpg"),
    UserDev(id: UUID().uuidString, alias: "hazelnet", imageUrl: "https://i.pinimg.com/280x280_RS/7a/7a/d2/7a7ad25b2bcc8f5fd7fe7100c9449399.jpg"),
    UserDev(id: UUID().uuidString, alias: "shadownexus", imageUrl: "https://i.pinimg.com/280x280_RS/40/01/0b/40010bb8fb1dda219f37a22bf412713a.jpg"),
    UserDev(id: UUID().uuidString, alias: "maplelane", imageUrl: "https://i.pinimg.com/280x280_RS/97/91/4e/97914e8e6557a18d5b34065690b1d43d.jpg"),
    UserDev(id: UUID().uuidString, alias: "evermint", imageUrl: "https://i.pinimg.com/280x280_RS/40/c7/ce/40c7ced7b37fcb5d83ff26399f5d38f6.jpg"),
    UserDev(id: UUID().uuidString, alias: "orbit.coast", imageUrl: "https://i.pinimg.com/280x280_RS/8b/79/a4/8b79a4432454bb33c713d25182be5a6b.jpg"),
    UserDev(id: UUID().uuidString, alias: "venusrising", imageUrl: "https://i.pinimg.com/280x280_RS/f5/4c/27/f54c27582e5760cd8df2bf08e7dc39b4.jpg"),
    UserDev(id: UUID().uuidString, alias: "mist.arcade", imageUrl: "https://i.pinimg.com/280x280_RS/63/83/3e/63833ed6c6c9e18ec8a164770e996003.jpg"),
    UserDev(id: UUID().uuidString, alias: "duskgrain", imageUrl: "https://i.pinimg.com/280x280_RS/a7/9b/b1/a79bb12753eb37c62e7b3f96e95c9367.jpg"),
    UserDev(id: UUID().uuidString, alias: "solar.forge", imageUrl: "https://i.pinimg.com/280x280_RS/f5/b8/ad/f5b8ad8d86b0dda8559e4d96832c1342.jpg"),
    UserDev(id: UUID().uuidString, alias: "emberlines", imageUrl: "https://i.pinimg.com/280x280_RS/cb/4c/86/cb4c86ff35c2b318e6ba92c4e4d2bae7.jpg"),
    UserDev(id: UUID().uuidString, alias: "frostedphase", imageUrl: "https://i.pinimg.com/280x280_RS/2f/89/5e/2f895e3c687868f4389fa55ff4ef0090.jpg"),
    UserDev(id: UUID().uuidString, alias: "coastaltide", imageUrl: "https://i.pinimg.com/280x280_RS/cc/86/b3/cc86b311d291d782466e4ed2efcfc6d6.jpg"),
    UserDev(id: UUID().uuidString, alias: "nightfall", imageUrl: "https://i.pinimg.com/280x280_RS/d1/0a/b3/d10ab33c36d05155c2b785533425e0fd.jpg"),
    UserDev(id: UUID().uuidString, alias: "warmgaze", imageUrl: "https://i.pinimg.com/280x280_RS/59/23/7b/59237bcdda00a6bd3a5c2e6dbabacb98.jpg")
]

let biomeOne: [Entity] = {
    let parentEntity = Entity(
        id: "0",
        username: "autobahn",
        avatar: "https://i.pinimg.com/474x/9f/38/61/9f38614bb1acaad50e1959f4e3d5768c.jpg",
        text: "yall are insane. this is peak, sounds like autolux. also, its not like theyre hiding the fact that they took inspiration",
        created_at: Date(timeIntervalSinceNow: -3600)
    )

    return [
        parentEntity,
        Entity(
            id: "4",
            username: "vjeranski",
            avatar: "https://d2w9rnfcy7mm78.cloudfront.net/31132288/original_b3573ce965ab3459b25ab0977beec40b.jpg",
            text: "have you all checked out azusa saga (for tracy hyde, aprilblue)'s idol group yet",
            created_at: Date(timeIntervalSinceNow: -1200),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif",
                text: "sentimental outlook on Hotel Insomnia, mainly since it soundtracked a good portion of my trip to Japan",
                created_at: Date(timeIntervalSinceNow: -2400),
                attachments: [
                    SongAttachment(id: "idk",
                                   artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/b9/c4/a6/b9c4a69d-a8f4-019f-d4a5-05b2bbc30e94/4538182723500_cov.jpg/632x632bb.webp",
                                   name: "he(r)art",
                                   artistName: "For Tracy Hyde",
                                   color: "#33253b")
                ]
            )
        ),
        Entity(
            id: "5",
            username: "zack+",
            avatar: "https://i.pinimg.com/474x/fd/f1/21/fdf12119ecb977a68bc10d185dbb2523.jpg",
            text: """
            Really a shame for Tracy Hyde broke up. The goats of Japanese shoegaze. At least Azusa is still writing music for other groups so their legacy lives on in Aprilblue, Fennel, Tricot, RAY etc. But man I’ll miss them
            """,
            created_at: Date(timeIntervalSinceNow: -600),
            parent: Entity(
                id: "1",
                username: "qwertyyy",
                avatar: "https://i.pinimg.com/originals/6f/61/30/6f61303117eb9da74e554f75ddf913d3.gif",
                text: "sentimental outlook on Hotel Insomnia, mainly since it soundtracked a good portion of my trip to Japan",
                created_at: Date(timeIntervalSinceNow: -2400),
                attachments: [
                    SongAttachment(id: "idk",
                                   artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music71/v4/90/74/50/9074507a-c12c-50e5-122f-5d9b4918d1f2/4538182661741_cov.jpg/632x632bb.webp",
                                   name: "Film Bleu",
                                   artistName: "For Tracy Hyde",
                                   color: "#FFF")
                ]
            ),
            attachments: [
                SongAttachment(id: "idk",
                               artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/19/76/d1/1976d17a-d900-5969-d37f-612127b0e302/4538182836460_cov.jpg/632x632bb.webp",
                               name: "New Young City",
                               artistName: "For Tracy Hyde",
                               
                               color: "#d2dcf0")
            ]
        )
    ]
}()

// let biomeTwo: [Entity] = {
//     let parentEntity = Entity(
//         id: "0",
//         username: "neonDream",
//         avatar: "https://i.pinimg.com/474x/5a/4c/73/5a4c73cb4ea137d5b52d7a3c1459c42a.jpg",
//         text: "This installation is insane. Feels like walking inside a memory you can’t quite remember. Wild stuff.",
//         created_at: Date(timeIntervalSinceNow: -3600),
//         attachments: [
//             SongAttachment(id: "exhibit2024",
//                            artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/02/1d/30/021d3036-5503-3ed3-df00-882f2833a6ae/17UM1IM17026.rgb.jpg/632x632bb.webp",
//                            name: "dont smile at me",
//                            artistName: "Billie Eilish",
//                            color: "#FFF")
//         ]
//     )
//
//     return [
//         parentEntity,
//         Entity(
//             id: "2",
//             username: "synesthesia",
//             avatar: "https://i.pinimg.com/474x/16/a2/5d/16a25d5a1db5b04f4cf1f519d8070c07.jpg",
//             text: "I get that, but if you stick around, it starts pulling you in. It’s almost hypnotic, like it’s pulling memories out of your head.",
//             created_at: Date(timeIntervalSinceNow: -2800),
//             parent: parentEntity
//         ),
//         Entity(
//             id: "3",
//             username: "echoVerse",
//             avatar: "https://i.pinimg.com/474x/9b/3c/11/9b3c11429ec2b25b0135566ad3e6c482.jpg",
//             text: "Alright, maybe I’ll give it another shot. I guess I was expecting something less… polished.",
//             created_at: Date(timeIntervalSinceNow: -2400),
//             parent: Entity(id: "1", username: "echoVerse", avatar: "", text: "", created_at: Date())
//         )
//     ]
// }()

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
                           artistName: "FKA Twigs",
                           color: "#FFF")
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
                               artistName: "Charli XCX",
                               color: "#FFF")
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
                                   artistName: "Kanye West",
                                   color: "#FFF")
                ]
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
