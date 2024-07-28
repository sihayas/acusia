//
//  UINavigationManager.swift
//  InstagramTransition
//
//  Created by decoherence on 5/24/24.
//


import SwiftUI

class NavManager: ObservableObject {
    static let shared = NavManager()
    
    @Published var selectedSound: APIAppleSoundData?
    @Namespace public var animation
    @Published var isExpanded: Bool = false
    @Published var isViewingEntry: Bool = false
    
    init() {}
    
    func setSelectedSound(_ result: APIAppleSoundData) {
        selectedSound = result
    }
}
