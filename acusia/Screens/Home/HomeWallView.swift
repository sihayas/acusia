//
//  StickerWallView.swift
//  acusia
//
//  Created by decoherence on 8/6/24.
//

import CoreMotion
import MusicKit
import SwiftUI

struct HomeWallView: View {
    // MARK: - Global Properties

    @EnvironmentObject var musicKitManager: MusicKitManager
    
    @Binding var homePath: NavigationPath
    let initialUserData: APIUser?
    let userResult: UserResult?
    
    @State private var keyboardOffset: CGFloat = 0
    @State private var showSettings = false
    @State private var searchSheet = false
    @State private var searchText = "joji"
    
    // MARK: Sticker Wall Config

    // Load animation
    @State var viewVisible = false
    @State var triggerSensoryFeedback: Int = 0
    
    // zIndex
    @State var zIndexMap: [StickerViewType: Int] = [:]
    @State var nextZIndex: Int = 1
    
    // 3D Config
    @State var activeSticker: StickerViewType? = nil
    @State var xAxisSliderValueHello: Double = 60
    
    @State var zAxisSliderValueHello: Double = -45
    
    @State var offsetSliderValueHello: Double = 15
    
    // Resetting
    @State var resetStickerOffset = false
    
    // MARK: Animation States

    @State var expandEssentialStates = [false, false, false]
    @State var showRecents = false
    
    var body: some View {
        ZStack {
            // MARK: Sticker Interface
            ZStack {
                HelloStickerView(zIndexMap: $zIndexMap,
                                 nextZIndex: $nextZIndex,
                                 resetStickerOffset: $resetStickerOffset,
                                 xAxisSliderValue: $xAxisSliderValueHello,
                                 zAxisSliderValue: $zAxisSliderValueHello,
                                 offsetSliderValue: $offsetSliderValueHello,
                                 activeSticker: $activeSticker)
                    .offset(x: 0, y: -160)
                    .rotationEffect(Angle(degrees: activeSticker == .sticker_zero ? 0 : 20))
                    .scaleEffect(viewVisible ? 1 : 2)
                    .blur(radius: viewVisible ? 0.0 : 30.0)
                    .opacity(viewVisible ? 1.0 : 0.0)
                    .animation(.spring().delay(0), value: viewVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            self.triggerSensoryFeedback += 1
                        }
                    }
                    .sensoryFeedback(.impact(weight: .heavy), trigger: triggerSensoryFeedback)
                    .zIndex(Double(zIndexMap[.sticker_zero] ?? 0))
            }
            .blur(radius: showRecents ? 12 : 0)
            .animation(.spring(), value: showRecents)
            
            // MARK: User Data Buttons
            ZStack {
                AsyncImage(url: URL(string: userResult?.image ?? initialUserData?.image ?? "")) { image in
                    image
                        .resizable()
                        .frame(width: 112, height: 112)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.thinMaterial, lineWidth: 1))
                } placeholder: {
                    ProgressView()
                }
                .blur(radius: showRecents ? 12 : 0)
                .animation(.spring(), value: showRecents)
                
                VStack {
                    Text("Alia")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    ZStack(alignment: .bottom) {
                        // Buttons
                        if expandEssentialStates.contains(true) {
                            EmptyView()
                        } else {
                            HStack(alignment: .bottom) {
                                // History Button
                                Button {
                                    showRecents.toggle()
                                } label: {
                                    Image(systemName: "timelapse")
                                        .symbolEffect(.scale, isActive: showSettings)
                                        .font(.system(size: 16))
                                        .frame(width: 32, height: 32)
                                        .background(.ultraThinMaterial, in: .circle)
                                        .contentShape(.circle)
                                        .foregroundColor(.white)
                                        .symbolRenderingMode(.multicolor)
                                }
                                
                                Spacer()
                                
                                // Search Button
                                Button {
                                    searchSheet.toggle()
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .symbolEffect(.scale, isActive: showSettings)
                                        .font(.system(size: 16))
                                        .frame(width: 32, height: 32)
                                        .background(.ultraThinMaterial, in: .circle)
                                        .contentShape(.circle)
                                        .foregroundColor(.white)
                                        .symbolRenderingMode(.multicolor)
                                }
                                
                                // Settings Button
                                Menu {
                                    Menu("Data") {
                                        Section("Permanently erase user data from the heavens.") {
                                            Button(role: .destructive) {
                                                // Action for "Add to Favorites"
                                            } label: {
                                                Label("Delete", systemImage: "xmark.icloud.fill")
                                            }
                                        }
                                        
                                        Section("Temporarily disable user in the heavens.") {
                                            Button {
                                                // Action for "Add to Favorites"
                                            } label: {
                                                Label("Archive", systemImage: "exclamationmark.icloud.fill")
                                            }
                                        }
                                        
                                        Section("Download user data from the heavens.") {
                                            Button {
                                                // Action for "Add to Favorites"
                                            } label: {
                                                Label("Export", systemImage: "icloud.and.arrow.down.fill")
                                            }
                                        }
                                    }
                                    Section("System") {
                                        Button {
                                            // Action for "Add to Bookmarks"
                                        } label: {
                                            Label("Disconnect", systemImage: "person.crop.circle.fill.badge.xmark")
                                        }
                                    }
                                    Section("Identity") {
                                        Button {
                                            // Action for "Add to Favorites"
                                        } label: {
                                            Label("Name", systemImage: "questionmark.text.page.fill")
                                        }
                                        Button {
                                            // Action for "Add to Bookmarks"
                                        } label: {
                                            Label("Avatar", systemImage: "person.circle.fill")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "gear")
                                        .symbolEffect(.scale, isActive: showSettings)
                                        .font(.system(size: 20))
                                        .frame(width: 32, height: 32)
                                        .background(.ultraThinMaterial, in: .circle)
                                        .contentShape(.circle)
                                        .foregroundColor(.white)
                                        .symbolRenderingMode(.multicolor)
                                }
                            }
                            .transition(.blurReplace)
                        }
                        
                        // Essentials
                        HStack(alignment: .bottom) {
                            HStack(spacing: -18) {
                                ForEach(Array(musicKitManager.recentlyPlayedSongs.prefix(3).enumerated()), id: \.offset) { index, song in
                                    if let artwork = song.artwork {
                                        ArtworkImage(artwork, width: 136, height: 136)
                                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                                    .stroke(Color.white, lineWidth: 4)
                                            )
                                            .rotationEffect(index == 0 ? .degrees(-8) : index == 2 ? .degrees(8) : .degrees(0), anchor: .center)
                                            .offset(y: index == 1 ? -8 : 0)
                                            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
                                            .scaleEffect(expandEssentialStates[index] ? 1.0 : 0.2, anchor: index == 0 ? .bottomTrailing : index == 2 ? .bottomLeading : .bottom)
                                            .offset(x: expandEssentialStates[index] ? 0 : index == 0 ? 48 : index == 2 ? -48 : 0)
                                            .zIndex(Double(index * -1))
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        for index in 0..<3 {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.07) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                                                    expandEssentialStates[index] = true
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        for index in 0..<3 {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.07) {
                                                withAnimation(.spring()) {
                                                    expandEssentialStates[index] = false
                                                }
                                            }
                                        }
                                    }
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 24)
            
            // MARK: Recently Played
            ZStack {
                RecentlyPlayedList(isVisible: $showRecents, songs: musicKitManager.recentlyPlayedSongs)
                    .padding(24)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .onAppear {
            viewVisible.toggle()
        }
        // MARK: - Search Sheet
        .sheet(isPresented: $searchSheet) {
            SearchSheet()
        }
    }
}

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var yaw: Double = 0.0
    
    var motionManager = CMMotionManager()
    var initialPitch: Double = 0.0
    var initialRoll: Double = 0.0
    var relativePitch: Double = 0.0
    var relativeRoll: Double = 0.0
    var pitchChangeSnapshot: Double = 0.0
    var rollChangeSnapshot: Double = 0.0
    var shouldUpdatePitch: Bool = true
    var shouldUpdateRoll: Bool = true
    
    var timer: Timer?
    
    private init() {
        startMotionUpdates()
//        startTimer()
    }
    
    private func startMotionUpdates() {
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, _ in
            if let motionData = motionData {
                self?.pitch = motionData.attitude.pitch
                self?.roll = motionData.attitude.roll
                self?.yaw = motionData.attitude.yaw

                if self?.initialPitch == 0.0 {
                    self?.initialPitch = motionData.attitude.pitch
                }

                if self?.initialRoll == 0.0 {
                    self?.initialRoll = motionData.attitude.roll
                }

                if let initialPitch = self?.initialPitch, let initialRoll = self?.initialRoll {
                    self?.relativePitch = (initialPitch - motionData.attitude.pitch) * -1 + 0.05
                    self?.relativeRoll = (initialRoll - motionData.attitude.roll) * -1
                }
            }
        }
    }
    
//    private func startTimer() {
//        var lastUpdate = Date()
//
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//
//            let now = Date()
//            let timeSinceLastUpdate = now.timeIntervalSince(lastUpdate)
//
//            if timeSinceLastUpdate >= 2.0 {
//                if self.shouldUpdatePitch {
//                    if abs(self.pitchChangeSnapshot - self.relativePitch) < 0.02 {
//                        self.initialPitch = self.pitch
//                    }
//                    self.pitchChangeSnapshot = self.relativePitch
//                    self.shouldUpdatePitch = false
//                }
//
//                if self.shouldUpdateRoll {
//                    if abs(self.rollChangeSnapshot - self.relativeRoll) < 0.02 {
//                        self.initialRoll = self.roll
//                    }
//                    self.rollChangeSnapshot = self.relativeRoll
//                    self.shouldUpdateRoll = false
//                }
//
//                self.shouldUpdatePitch = true
//                self.shouldUpdateRoll = true
//
//                lastUpdate = now
//            }
//        }
//    }
}

enum StickerViewType {
    case sticker_zero, sticker_one, sticker_two, sticker_three, sticker_four, sticker_five, sticker_six
}
