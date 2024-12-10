//
//  AuthModel.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import SwiftUI

struct User: Codable {
    let user_id: Int64
    let alias: String?
    let apple_id: String?
    let auth_provider: String?
    let avatar: Image_UDT?
    let blocked_users: Set<Int64>?
    let created_at: Date
    let email: String?
    let followers_count: Int64
    let following_count: Int64
    let images_sent: Int64
    let last_played: Music_UDT?
    let messages_sent: Int64
    let songs_sent: Int64
    let status: String?
}
