//
//  StickerWallView.swift
//  acusia
//
//  Created by decoherence on 8/6/24.
//

import CoreMotion
import SwiftUI

struct MeshTransform: ViewModifier, Animatable {
    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
        get {
            AnimatableData(AnimatablePair(squeezeProgressX, squeezeProgressY), squeezeTranslationY)
        }
        set {
            squeezeProgressX = newValue.first.first
            squeezeProgressY = newValue.first.second
            squeezeTranslationY = newValue.second
        }
    }

    var offset: CGSize
    var currentRotation: Angle
    var currentMagnification: CGFloat
    var pinchMagnification: CGFloat
    var twistAngle: Angle

    var squeezeCenterX: CGFloat
    var squeezeProgressX: CGFloat
    var squeezeProgressY: CGFloat
    var squeezeTranslationY: CGFloat

    init(squeezeProgressX: CGFloat, squeezeProgressY: CGFloat, squeezeTranslationY: CGFloat, squeezeCenterX: CGFloat, offset: CGSize, currentRotation: Angle, currentMagnification: CGFloat, pinchMagnification: CGFloat, twistAngle: Angle) {
        self.squeezeProgressX = squeezeProgressX
        self.squeezeProgressY = squeezeProgressY
        self.squeezeTranslationY = squeezeTranslationY
        self.squeezeCenterX = squeezeCenterX
        self.offset = offset
        self.currentRotation = currentRotation
        self.currentMagnification = currentMagnification
        self.pinchMagnification = pinchMagnification
        self.twistAngle = twistAngle
    }

    func shader() -> Shader {
        Shader(function: .init(library: .default, name: "distortion"), arguments: [
            .boundingRect,
            .float(squeezeCenterX),
            .float(squeezeProgressX),
            .float(squeezeProgressY),
            .float(squeezeTranslationY)
        ])
    }

    func body(content: Content) -> some View {
        content
            .distortionEffect(shader(), maxSampleOffset: CGSize(width: 500, height: 500))
            .scaleEffect(currentMagnification * pinchMagnification)
            .rotationEffect(currentRotation + twistAngle, anchor: .center)
            .offset(offset)
    }
}

struct UserScreen: View {
    // Data
    @StateObject private var viewModel: UserViewModel
//    @EnvironmentObject var auth: Auth
    
    let initialUserData: APIUser?
    let userResult: UserResult?
    
    init(initialUserData: APIUser?, userResult: UserResult?) {
        self.initialUserData = initialUserData
        self.userResult = userResult
        self._viewModel = StateObject(wrappedValue: UserViewModel())
    }
    
    private var pageUserId: String {
        userResult?.id ?? initialUserData?.id ?? ""
    }
    
    @State var isFollowing = false
    var follow: () -> Void {
        return {
            isFollowing.toggle()
        }
    }
    
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
    
    // Background Config
    @State var backgroundImageIndex = 4
    
    private func loadBackgroundImage() -> Image {
        switch backgroundImageIndex {
        case 1:
            return Image("background-7")
        case 2:
            return Image("background-2")
        case 3:
            return Image("background-3")
        case 4:
            return Image("background-8")
        case 5:
            return Image("")
        default:
            return Image("background")
        }
    }
    
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
        
        let longTap = LongPressGesture(minimumDuration: 1.0)
            .onEnded { _ in
                backgroundImageIndex += 1
                if backgroundImageIndex > 5 {
                    backgroundImageIndex = 1
                }
            }
        
        let combinedGestures = doubleTapReset
            .simultaneously(with: longTap)
            .simultaneously(with: tapReset)
        
        ZStack {
//            loadBackgroundImage()
//                .resizable()
//                .scaledToFill()
//                .edgesIgnoringSafeArea(.all)
//                .gesture(combinedGestures)
            
            // 3D Config Slider Interface
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
            
            // User data interface
            VStack() {
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
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("7643")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 2)
                        
                        HStack {
                            Text("REVERIE")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("967")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 2)
                        
                        HStack {
                            Text("SOUND")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("12.3K")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.4, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//                .border(Color.green.opacity(1.0), width: 1)
                .padding(.horizontal, 24)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: follow) {
                        // Follow button
                        Image(systemName: isFollowing ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.plus")
                            .contentTransition(
                                .symbolEffect(.replace)
                            )
                            .font(.system(size: 24))
                            .frame(width: 48, height: 48)
                            .background(.ultraThinMaterial, in: .circle)
                            .contentShape(.circle)
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.multicolor)
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//            .border(Color.red.opacity(1.0), width: 1)
            .padding(.top, 60)
            .allowsHitTesting(false)
            
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
        .ignoresSafeArea(.all, edges: .top)
        .background(Color.black)
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

#Preview {
    UserScreen(initialUserData: nil, userResult: UserResult(id: "3f6a2219-8ea1-4ff1-9057-6578ae3252af", username: "decoherence", image: "https://i.pinimg.com/474x/45/8a/ce/458ace69027303098cccb23e3a43e524.jpg"))
}
    
