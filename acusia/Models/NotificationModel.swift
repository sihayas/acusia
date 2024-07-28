//
//  NotificationModel.swift
//  acusia
//
//  Created by decoherence on 6/22/24.
//

struct NotificationResponse: Codable {
    let data: [Notif]
}

struct Notif: Codable {
    let count: Int
    let author_id: String
    let source_id: String
    let source_type: SourceType
    let created_at: String
    let author: APIUser
    let sound: APISound?
}

enum SourceType: String, Codable {
    case heart
    case follow
}

