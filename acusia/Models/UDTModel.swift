//
//  UDTModel.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import SwiftUI

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
