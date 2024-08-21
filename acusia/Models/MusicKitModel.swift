//
//  MusicKitModel.swift
//  acusia
//
//  Created by decoherence on 8/20/24.
//
import MusicKit
import SwiftUI

struct SongModel: Identifiable {
    let id: String
    let title: String
    let artistName: String
    let artwork: Artwork?
}
