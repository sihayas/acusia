//
//  AuthModel.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import SwiftUI

struct AuthResponse: Codable {
    let token: String
    let user: UserProfile
}

struct UserProfile: Codable {
    let user_id: Int64
    let alias: String?
    let apple_id: String?
    let auth_provider: String?
    let avatar: Image_UDT? // Optional because it can be null
    let blocked_users: Set<Int64>? // Optional because it can be null
    let created_at: Date
    let email: String?
    let followers_count: Int
    let following_count: Int
    let images_sent: Int
    let last_played: Music_UDT? // Optional because it can be null
    let messages_sent: Int
    let songs_sent: Int
    let status: String?
}

struct Image_UDT: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct Music_UDT: Codable {
    let id: String
    let isbn: String?
    let upc: String?
    let music_type: String
}
