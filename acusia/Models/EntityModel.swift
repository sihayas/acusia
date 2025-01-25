//
//  EntityModel.swift
//  acusia
//
//  Created by decoherence on 11/10/24.
//
import SwiftUI

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

class PhotoAttachment: Attachment, Identifiable {
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
    ),
    Entity(
        id: "11",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "accidentally overslept again. coffee is my only friend now.",
        created_at: Date(timeIntervalSinceNow: -600)
    ),
    Entity(
        id: "12",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "my to-do list is longer than my will to live. send help.",
        created_at: Date(timeIntervalSinceNow: -300)
    ),
    Entity(
        id: "13",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "why do brands change perfectly good logos? y’all bored or something??",
        created_at: Date(timeIntervalSinceNow: -180)
    ),
    Entity(
        id: "14",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "thought about adulting, then took a nap instead. #winning.",
        created_at: Date(timeIntervalSinceNow: -60)
    ),
    // Additional samples to reach 24
    Entity(
        id: "15",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "someone gave me a succulent. let's see how long it survives.",
        created_at: Date(timeIntervalSinceNow: -50)
    ),
    Entity(
        id: "16",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "just realized i have 10k unread emails... oh well.",
        created_at: Date(timeIntervalSinceNow: -45)
    ),
    Entity(
        id: "17",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "someone please remind me to pay my bills on time.",
        created_at: Date(timeIntervalSinceNow: -40)
    ),
    Entity(
        id: "18",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "spent 30 min looking for the perfect snack. found cookies. winning.",
        created_at: Date(timeIntervalSinceNow: -35)
    ),
    Entity(
        id: "19",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "why is real life never as fun as my daydreams??",
        created_at: Date(timeIntervalSinceNow: -30)
    ),
    Entity(
        id: "20",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "gave that new album a try. kinda overrated imo.",
        created_at: Date(timeIntervalSinceNow: -25)
    ),
    Entity(
        id: "21",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "everybody’s out having a life, i’m here binge-watching memes. no regrets.",
        created_at: Date(timeIntervalSinceNow: -20)
    ),
    Entity(
        id: "22",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "math randomly decided to abandon me today. i’m not mad, just disappointed.",
        created_at: Date(timeIntervalSinceNow: -15)
    ),
    Entity(
        id: "23",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "who decided weekends are only two days? we need at least three.",
        created_at: Date(timeIntervalSinceNow: -10)
    ),
    Entity(
        id: "24",
        username: "debbievthang",
        avatar: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg",
        text: "just realized how late it is... guess i’m sacrificing sleep again.",
        created_at: Date(timeIntervalSinceNow: -5)
    )
]
