//
//  EntityModel.swift
//  acusia
//
//  Created by decoherence on 11/10/24.
//
import SwiftUI

class Biome: Identifiable {
    let id = UUID()
    private(set) var entities: [Entity]

    init(entities: [Entity]) {
        self.entities = entities
    }
}

class Entity: Equatable, Identifiable {
    let id: String
    let username: String
    let avatar: String
    let text: String
    let created_at: Date
    let parent: Entity?
    var attachments: [Attachment]

    init(id: String,
         username: String,
         avatar: String,
         text: String,
         created_at: Date,
         parent: Entity? = nil,
         attachments: [Attachment] = [])
    {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.text = text
        self.created_at = created_at
        self.parent = parent
        self.attachments = attachments
    }

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs.id == rhs.id &&
            lhs.username == rhs.username &&
            lhs.avatar == rhs.avatar &&
            lhs.text == rhs.text &&
            lhs.attachments.count == rhs.attachments.count &&
            lhs.created_at == rhs.created_at &&
            lhs.parent?.id == rhs.parent?.id
    }
}

extension Entity {
    func getSongAttachment() -> SongAttachment? {
        return attachments.first { $0 is SongAttachment } as? SongAttachment
    }
}

extension Entity {
    func getPhotoAttachments() -> [PhotoAttachment] {
        attachments.compactMap { $0 as? PhotoAttachment }
    }
}

protocol Attachment {
    var id: String { get }
}

class SongAttachment: Attachment {
    let id: String
    let artwork: String
    let name: String
    let artistName: String
    let color: String
    
    init(id: String, artwork: String, name: String, artistName: String, color: String) {
        self.id = id
        self.artwork = artwork
        self.name = name
        self.artistName = artistName
        self.color = color
    }
}

class PhotoAttachment: Attachment {
    let id: String
    let url: String
    let width: Int
    let height: Int

    init(id: String, url: String, width: Int, height: Int) {
        self.id = id
        self.url = url
        self.width = width
        self.height = height
    }
}

class VoiceAttachment: Attachment {
    let id: String
    let url: String

    init(id: String, url: String) {
        self.id = id
        self.url = url
    }
}

let userHistorySample: [Entity] = [
    Entity(
        id: "1",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "stayed up way too late watching random vids... i regret nothing.",
        created_at: Date(timeIntervalSinceNow: -3600)
    ),
    Entity(
        id: "2",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "ok but why does my Wi-Fi pick the worst times to act up??",
        created_at: Date(timeIntervalSinceNow: -3200)
    ),
    Entity(
        id: "3",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "thinking about that one road trip we took last summer... we need to do that again.",
        created_at: Date(timeIntervalSinceNow: -2900)
    ),
    Entity(
        id: "4",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "forgot to charge my phone again 💀 why am i like this??",
        created_at: Date(timeIntervalSinceNow: -2700)
    ),
    Entity(
        id: "5",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "this group chat has been sus lately. is everyone just busy or what?",
        created_at: Date(timeIntervalSinceNow: -2400)
    ),
    Entity(
        id: "6",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "movie night soon?? i’ll bring snacks.",
        created_at: Date(timeIntervalSinceNow: -2100)
    ),
    Entity(
        id: "7",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "tried that pizza place downtown. garlic knots? amazing. the rest? meh.",
        created_at: Date(timeIntervalSinceNow: -1800)
    ),
    Entity(
        id: "8",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "early meetings should be illegal. that’s it. that’s the post.",
        created_at: Date(timeIntervalSinceNow: -1500)
    ),
    Entity(
        id: "9",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "saw a guy walking his cat on a leash today. 10/10 iconic.",
        created_at: Date(timeIntervalSinceNow: -1200)
    ),
    Entity(
        id: "10",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "been at this coffee shop for 2 hours and i still haven’t done any work. classic.",
        created_at: Date(timeIntervalSinceNow: -900)
    )
]

let biomePreviewOne: [Entity] = [
    Entity(
        id: "1",
        username: "DeborahVthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "unique pres, but it does feel a little too polished for my taste.",
        created_at: Date(timeIntervalSinceNow: -3000)
    ),
    Entity(
        id: "3",
        username: "echoVerse",
        avatar: "https://i.pinimg.com/280x280_RS/3e/6f/e2/3e6fe2a2aec4488e6bc937a5118b09dc.jpg",
        text: "Alright, maybe I’ll give it another shot. I guess I was expecting something less… polished.",
        created_at: Date(timeIntervalSinceNow: -2400),
        parent: Entity(
            id: "1",
            username: "DeborahVthang",
            avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
            text: "Honestly, the presentation is unique, but it does feel a little too polished for my taste.",
            created_at: Date(timeIntervalSinceNow: -3000)
        )
    ),
    Entity(
        id: "2",
        username: "synesthesia",
        avatar: "https://i.pinimg.com/280x280_RS/4c/ba/fb/4cbafbfab791255a004740a491e85f6d.jpg",
        text: "idk if it’s just me but if you stick around it kinda pulls you in lowkey like random core memories or smth",
        created_at: Date(timeIntervalSinceNow: -2800))
]

let biomePreviewTwo: [Entity] = [
    Entity(
        id: "0",
        username: "neonDream",
        avatar: "https://pbs.twimg.com/profile_images/1863668966167601152/OQ34VUQ-_400x400.png",
        text: "This installation is insane. Feels like walking inside a memory you can’t quite remember. Wild stuff.",
        created_at: Date(timeIntervalSinceNow: -3600),
        attachments: [
            SongAttachment(id: "exhibit2024",
                           artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/02/1d/30/021d3036-5503-3ed3-df00-882f2833a6ae/17UM1IM17026.rgb.jpg/632x632bb.webp",
                           name: "dont smile at me",
                           artistName: "Billie Eilish",
                           color: "#CDBC73")
        ]
    ),
    Entity(
        id: "1",
        username: "neonDream",
        avatar: "https://pbs.twimg.com/profile_images/1858518982908641280/z46-ENpf_400x400.jpg",
        text: "type shit",
        created_at: Date(timeIntervalSinceNow: -3600),
        attachments: [
            PhotoAttachment(
                id: "45",
                url: "https://img.vsco.co/cdn-cgi/image/width=960,height=720/1cd788/286914273/66f1aaf9b57f070427368575/vsco_092324.jpg",
                width: 960,
                height: 720
            ),
            PhotoAttachment(
                id: "455",
                url: "https://img.vsco.co/cdn-cgi/image/width=1136,height=1534/f69c13/151110606/65d5c41abeee27354493a551/vsco_022124.jpg",
                width: 1136,
                height: 1534
            ),
            PhotoAttachment(
                id: "4552",
                url: "https://img.vsco.co/cdn-cgi/image/width=1136,height=1513/f69c13/151110606/65d5c302b4f2ec346ea4f301/vsco_022124.jpg",
                width: 1136,
                height: 1513
            )
        ]
    ),
    Entity(
        id: "1",
        username: "DeborahVthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "Honestly, the presentation is unique, but it does feel a little too polished for my taste.",
        created_at: Date(timeIntervalSinceNow: -3000)
    )
]

let biomePreviewThree: [Entity] = [
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
        Really a shame for Tracy Hyde broke up. The goats of Japanese shoegaze. At least Azusa still writes music for other groups like Aprilblue, Fennel, Tricot, and RAY. Their legacy lives on, but man, I’ll miss them.
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
                           artwork: "https://is1-ssl.mzstatic.com/image/thumb/Music123/v4/2b/cb/44/2bcb44f7-306c-db16-91e7-d5c6a3bb994a/19UMGIM51757.rgb.jpg/632x632bb.webp",
                           name: "Ad Astra",
                           artistName: "Max Richter, Lorne Balfe",
                           color: "#091023")
        ]
    ),
    Entity(
        id: "1",
        username: "DeborahVthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "Honestly, the presentation is unique, but it does feel a little too polished for my taste.",
        created_at: Date(timeIntervalSinceNow: -3000)
    )
]

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
