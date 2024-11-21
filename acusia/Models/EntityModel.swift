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

protocol Attachment {
    var id: String { get }
    var type: String { get }
}

class SongAttachment: Attachment {
    let id: String
    let type = "song"
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
    let type = "photo"
    let url: String

    init(id: String, url: String) {
        self.id = id
        self.url = url
    }
}

class VoiceAttachment: Attachment {
    let id: String
    let type = "voice"
    let url: String

    init(id: String, url: String) {
        self.id = id
        self.url = url
    }
}

class Biome: Identifiable {
    let id = UUID()
    private(set) var entities: [Entity]

    init(entities: [Entity]) {
        self.entities = entities
    }
}
