//
//  StickerWallView.swift
//  acusia
//
//  Created by decoherence on 8/6/24.
//

import CoreMotion
import SwiftUI

struct UserScreen: View {
    // Data
    @StateObject private var viewModel = UserViewModel()
    
    @Binding var homePath: NavigationPath
    let initialUserData: APIUser?
    let userResult: UserResult?
    
    private var pageUserId: String {
        userResult?.id ?? initialUserData?.id ?? ""
    }
    
    @State private var keyboardOffset: CGFloat = 0
    @State var isFollowing = false
    @State var showSettings = false
    @State var searchSheet = false
    @State private var searchText = ""
    
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
    
    var body: some View {
        let tapReset = TapGesture(count: 1)
            .onEnded { _ in
                resetStickerOffset.toggle()
                
                withAnimation(.spring(response: 0.36, dampingFraction: 0.86, blendDuration: 0)) {
                    xAxisSliderValueHello = 60
                        
                    zAxisSliderValueHello = -45
                        
                    offsetSliderValueHello = 15
                }
            }
        
        let doubleTapReset = TapGesture(count: 2)
            .onEnded { _ in
                viewVisible.toggle()
                activeSticker = nil
            }
        
        ZStack {
            // MARK: 3D Config Slider Interface
            ZStack {
                VStack {
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .frame(height: 84)
                                .foregroundColor(.black.opacity(0.5))
                                .blendMode(.overlay)
                                .background(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.black.opacity(0.10), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            VStack(spacing: 8) {
                                HStack {
                                    Text("X-axis")
                                        .font(.system(size: 15, weight: .medium))
                                        .opacity(0.4)
                                    Spacer()
                                    Text({
                                        if activeSticker == .sticker_zero {
                                            return "\(xAxisSliderValueHello, specifier: "%.0f")"
                                        } else {
                                            return "0"
                                        }
                                    }())
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .opacity(0.4)
                                }
                                Slider(
                                    value: Binding(
                                        get: {
                                            if let activeSticker = activeSticker {
                                                return xAxisSliderValueHello
                                            }
                                            return 0 // Default value
                                        },
                                        set: { newValue in
                                            if let activeSticker = activeSticker {
                                                xAxisSliderValueHello = newValue
                                            }
                                        }
                                    ),
                                    in: 0...180,
                                    step: 1
                                )
                            }
                            .padding(.leading, 14)
                            .padding(.trailing, 14)
                        }
                        .frame(height: 84)
                        Spacer()
                            .frame(width: 8)
                        ZStack {
                            Rectangle()
                                .frame(height: 84)
                                .foregroundColor(.black.opacity(0.5))
                                .blendMode(.overlay)
                                .background(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.black.opacity(0.10), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Z-axis")
                                        .font(.system(size: 15, weight: .medium))
                                        .opacity(0.4)
                                    Spacer()
                                    Text({
                                        if activeSticker == .sticker_zero {
                                            return "\(zAxisSliderValueHello, specifier: "%.0f")"
                                        } else {
                                            return "0"
                                        }
                                    }())
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .opacity(0.4)
                                }
                                Slider(
                                    value: Binding(
                                        get: {
                                            if let activeSticker = activeSticker {
                                                return zAxisSliderValueHello
                                            }
                                            return 0 // Default value
                                        },
                                        set: { newValue in
                                            if let activeSticker = activeSticker {
                                                zAxisSliderValueHello = newValue
                                            }
                                        }
                                    ),
                                    in: -180...180,
                                    step: 1
                                )
                            }
                            .padding(.leading, 14)
                            .padding(.trailing, 14)
                        }
                        .frame(height: 84)
                    }
                    
                    ZStack {
                        Rectangle()
                            .frame(height: 84)
                            .foregroundColor(.black.opacity(0.5))
                            .blendMode(.overlay)
                            .background(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.black.opacity(0.10), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        VStack(spacing: 8) {
                            HStack {
                                Text("Offset difference")
                                    .font(.system(size: 15, weight: .medium))
                                    .opacity(0.4)
                                Spacer()
                                Text({
                                    if activeSticker == .sticker_zero {
                                        return "\(offsetSliderValueHello, specifier: "%.0f")"
                                    } else {
                                        return "0"
                                    }
                                }())
                                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                                    .opacity(0.4)
                            }
                            Slider(
                                value: Binding(
                                    get: {
                                        if let activeSticker = activeSticker {
                                            return offsetSliderValueHello
                                        }
                                        return 0 // Default value
                                    },
                                    set: { newValue in
                                        if let activeSticker = activeSticker {
                                            offsetSliderValueHello = newValue
                                        }
                                    }
                                ),
                                in: 0...100,
                                step: 1
                            )
                            .onChange(of: offsetSliderValueHello) {
                                // Trigger haptic feedback
                                let feedbackGenerator = UISelectionFeedbackGenerator()
                                feedbackGenerator.selectionChanged()
                            }
                        }
                        .padding(.leading, 14)
                        .padding(.trailing, 14)
                    }
                    .frame(height: 84)
                }
            }
            .zIndex(20.0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 44)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .opacity(activeSticker != nil ? 1 : 0)
            
            AsyncImage(url: URL(string: userResult?.image ?? initialUserData?.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            
            // MARK: User data interface
            VStack {
                VStack(alignment: .leading) {
                    Text("@dracarys")
                        .font(.system(size: 27, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Divider()
                        .background(Color.primary)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    
                    Group {
                        HStack {
                            Text("FOLLOW")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("7643")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 2)
                        
                        HStack {
                            Text("REVERIE")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("967")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 2)
                        
                        HStack {
                            Text("SOUND")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("12.3K")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.4, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
//                    Button(action: {
//                        isFollowing.toggle()
//                    }) {
//                        Image(systemName: isFollowing ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.plus")
//                            .contentTransition(
//                                .symbolEffect(.replace)
//                            )
//                            .font(.system(size: 24))
//                            .frame(width: 48, height: 48)
//                            .background(.ultraThinMaterial, in: .circle)
//                            .contentShape(.circle)
//                            .foregroundColor(.primary)
//                            .symbolRenderingMode(.multicolor)
//                    }
                    
                    // Search
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 24)
            
            // Sticker Interface
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
            .onAppear {
                viewVisible.toggle()
            }
        }
        .sheet(isPresented: $searchSheet) {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    // search text preview
                    Text(searchText.isEmpty ? "Index" :"Indexing \"\(searchText)\"")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                }
                .padding([.top, .horizontal], 24)
                
                SearchSheet(path: $homePath, searchText: $searchText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.black)
            .presentationCornerRadius(32)
            .overlay(
                VStack {
                    Spacer()
                    SearchBar(searchText: $searchText)
                        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
                        .padding(.horizontal, 24)
                        .offset(y: -keyboardOffset)
                }
                .frame(width: UIScreen.main.bounds.width, alignment: .bottom)
            )
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                withAnimation(.spring()) {
                    keyboardOffset = 32 
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    keyboardOffset = 0
                }
            }
        }
        .background(Color.black)
        .onAppear {
            searchSheet = false
        }
//        .onAppear {
//            Task {
//                await viewModel.fetchUserData(userId: "cba2086a-21e8-43d9-9c03-2bd5e9b651ff", pageUserId: pageUserId)
//            }
//        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
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
        startTimer()
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
    
    private func startTimer() {
        var lastUpdate = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            let now = Date()
            let timeSinceLastUpdate = now.timeIntervalSince(lastUpdate)

            if timeSinceLastUpdate >= 2.0 {
                if self.shouldUpdatePitch {
                    if abs(self.pitchChangeSnapshot - self.relativePitch) < 0.02 {
                        self.initialPitch = self.pitch
                    }
                    self.pitchChangeSnapshot = self.relativePitch
                    self.shouldUpdatePitch = false
                }

                if self.shouldUpdateRoll {
                    if abs(self.rollChangeSnapshot - self.relativeRoll) < 0.02 {
                        self.initialRoll = self.roll
                    }
                    self.rollChangeSnapshot = self.relativeRoll
                    self.shouldUpdateRoll = false
                }

                self.shouldUpdatePitch = true
                self.shouldUpdateRoll = true

                lastUpdate = now
            }
        }
    }
}

enum StickerViewType {
    case sticker_zero, sticker_one, sticker_two, sticker_three, sticker_four, sticker_five, sticker_six
}

enum TagColor: String, CaseIterable, Identifiable {
    case blue
    case brown
    case green
    case yellow
    case indigo
    case red
    case cyan

    var id: Self { self }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .brown: return .brown
        case .green: return .green
        case .yellow: return .yellow
        case .indigo: return .indigo
        case .red: return .red
        case .cyan: return .cyan
        }
    }
}

// #Preview {
//    UserScreen(initialUserData: nil, userResult: UserResult(id: "3f6a2219-8ea1-4ff1-9057-6578ae3252af", username: "decoherence", image: "https://i.pinimg.com/474x/45/8a/ce/458ace69027303098cccb23e3a43e524.jpg"))
// }
//
