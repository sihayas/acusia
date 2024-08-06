//
//  StickerWallView.swift
//  acusia
//
//  Created by decoherence on 8/6/24.
//

import SwiftUI
import CoreMotion

struct StickerWallView: View {
    // Load animation
    @State var viewVisible = false
    @State var triggerSensoryFeedback: Int = 0
    
    // zIndex
    @State var zIndexMap: [StickerViewType: Int] = [:]
    @State var nextZIndex: Int = 1
    
    // 3D Config
    @State var activeSticker: StickerViewType? = nil
    @State var xAxisSliderValueXcode: Double = 60
    @State var xAxisSliderValueHello: Double = 60
    @State var xAxisSliderValueSwift: Double = 60
    @State var xAxisSliderValueGift: Double = 60
    @State var xAxisSliderValueMemoji: Double = 60
    @State var xAxisSliderValueSwiftui: Double = 60
    @State var xAxisSliderValueBunny: Double = 60
    
    @State var zAxisSliderValueXcode: Double = -45
    @State var zAxisSliderValueHello: Double = -45
    @State var zAxisSliderValueSwift: Double = 0
    @State var zAxisSliderValueGift: Double = -35
    @State var zAxisSliderValueMemoji: Double = -45
    @State var zAxisSliderValueSwiftui: Double = -45
    @State var zAxisSliderValueBunny: Double = -30
    
    @State var offsetSliderValueXcode: Double = 40
    @State var offsetSliderValueHello: Double = 15
    @State var offsetSliderValueSwift: Double = 18
    @State var offsetSliderValueGift: Double = 16
    @State var offsetSliderValueMemoji: Double = 15
    @State var offsetSliderValueSwiftui: Double = 40
    @State var offsetSliderValueBunny: Double = 44
    
    // Resetting
    @State var resetStickerOffset = false
    
    // Background Config
    @State var backgroundImageIndex = 1
    
    private func loadBackgroundImage() -> Image {
        switch backgroundImageIndex {
        case 1:
            return Image("background")
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
            .onEnded {(value) in
                resetStickerOffset.toggle()
                
                withAnimation(.spring(response: 0.36, dampingFraction: 0.86, blendDuration: 0)) {
                        xAxisSliderValueXcode = 60
                        xAxisSliderValueHello = 60
                        xAxisSliderValueSwift = 60
                        xAxisSliderValueGift = 60
                        xAxisSliderValueMemoji = 60
                        xAxisSliderValueSwiftui = 60
                        xAxisSliderValueBunny = 60
                        
                        zAxisSliderValueXcode = -45
                        zAxisSliderValueHello = -45
                        zAxisSliderValueSwift = 0
                        zAxisSliderValueGift = -35
                        zAxisSliderValueMemoji = -45
                        zAxisSliderValueSwiftui = -45
                        zAxisSliderValueBunny = -30
                        
                        offsetSliderValueXcode = 40
                        offsetSliderValueHello = 15
                        offsetSliderValueSwift = 18
                        offsetSliderValueGift = 16
                        offsetSliderValueMemoji = 15
                        offsetSliderValueSwiftui = 40
                        offsetSliderValueBunny = 44
                }
        }
        
        let doubleTapReset = TapGesture(count: 2)
            .onEnded {(value) in
                viewVisible.toggle()
                activeSticker = nil
        }
        
        let longTap = LongPressGesture(minimumDuration: 1.0)
            .onEnded {(value) in
                backgroundImageIndex += 1
                if backgroundImageIndex > 5 {
                    backgroundImageIndex = 1
                }
        }
        
        let combinedGestures = doubleTapReset
            .simultaneously(with: longTap)
            .simultaneously(with: tapReset)
        
        
        ZStack {
            loadBackgroundImage()
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .gesture(combinedGestures)
            
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
                                        if activeSticker == .xcode {
                                            return "\(xAxisSliderValueXcode, specifier: "%.0f")"
                                        } else if activeSticker == .hello {
                                            return "\(xAxisSliderValueHello, specifier: "%.0f")"
                                        } else if activeSticker == .swift {
                                            return "\(xAxisSliderValueSwift, specifier: "%.0f")"
                                        } else if activeSticker == .gift {
                                            return "\(xAxisSliderValueGift, specifier: "%.0f")"
                                        } else if activeSticker == .memoji {
                                            return "\(xAxisSliderValueMemoji, specifier: "%.0f")"
                                        } else if activeSticker == .swiftui {
                                            return "\(xAxisSliderValueSwiftui, specifier: "%.0f")"
                                        } else if activeSticker == .bunny {
                                            return "\(xAxisSliderValueBunny, specifier: "%.0f")"
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
                                                switch activeSticker {
                                                case .xcode:
                                                    return xAxisSliderValueXcode
                                                case .hello:
                                                    return xAxisSliderValueHello
                                                case .swift:
                                                    return xAxisSliderValueSwift
                                                case .gift:
                                                    return xAxisSliderValueGift
                                                case .memoji:
                                                    return xAxisSliderValueMemoji
                                                case .swiftui:
                                                    return xAxisSliderValueSwiftui
                                                case .bunny:
                                                    return xAxisSliderValueBunny
                                                }
                                            }
                                            return 0 // Default value
                                        },
                                        set: { newValue in
                                            if let activeSticker = activeSticker {
                                                switch activeSticker {
                                                case .xcode:
                                                    xAxisSliderValueXcode = newValue
                                                case .hello:
                                                    xAxisSliderValueHello = newValue
                                                case .swift:
                                                    xAxisSliderValueSwift = newValue
                                                case .gift:
                                                    xAxisSliderValueGift = newValue
                                                case .memoji:
                                                    xAxisSliderValueMemoji = newValue
                                                case .swiftui:
                                                    xAxisSliderValueSwiftui = newValue
                                                case .bunny:
                                                    xAxisSliderValueBunny = newValue
                                                }
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
                                        if activeSticker == .xcode {
                                            return "\(zAxisSliderValueXcode, specifier: "%.0f")"
                                        } else if activeSticker == .hello {
                                            return "\(zAxisSliderValueHello, specifier: "%.0f")"
                                        } else if activeSticker == .swift {
                                            return "\(zAxisSliderValueSwift, specifier: "%.0f")"
                                        } else if activeSticker == .gift {
                                            return "\(zAxisSliderValueGift, specifier: "%.0f")"
                                        } else if activeSticker == .memoji {
                                            return "\(zAxisSliderValueMemoji, specifier: "%.0f")"
                                        } else if activeSticker == .swiftui {
                                            return "\(zAxisSliderValueSwiftui, specifier: "%.0f")"
                                        } else if activeSticker == .bunny {
                                            return "\(zAxisSliderValueBunny, specifier: "%.0f")"
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
                                                switch activeSticker {
                                                case .xcode:
                                                    return zAxisSliderValueXcode
                                                case .hello:
                                                    return zAxisSliderValueHello
                                                case .swift:
                                                    return zAxisSliderValueSwift
                                                case .gift:
                                                    return zAxisSliderValueGift
                                                case .memoji:
                                                    return zAxisSliderValueMemoji
                                                case .swiftui:
                                                    return zAxisSliderValueSwiftui
                                                case .bunny:
                                                    return zAxisSliderValueBunny
                                                }
                                            }
                                            return 0 // Default value
                                        },
                                        set: { newValue in
                                            if let activeSticker = activeSticker {
                                                switch activeSticker {
                                                case .xcode:
                                                    zAxisSliderValueXcode = newValue
                                                case .hello:
                                                    zAxisSliderValueHello = newValue
                                                case .swift:
                                                    zAxisSliderValueSwift = newValue
                                                case .gift:
                                                    zAxisSliderValueGift = newValue
                                                case .memoji:
                                                    zAxisSliderValueMemoji = newValue
                                                case .swiftui:
                                                    zAxisSliderValueSwiftui = newValue
                                                case .bunny:
                                                    zAxisSliderValueBunny = newValue
                                                }
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
                                    if activeSticker == .xcode {
                                        return "\(offsetSliderValueXcode, specifier: "%.0f")"
                                    } else if activeSticker == .hello {
                                        return "\(offsetSliderValueHello, specifier: "%.0f")"
                                    } else if activeSticker == .swift {
                                        return "\(offsetSliderValueSwift, specifier: "%.0f")"
                                    } else if activeSticker == .gift {
                                        return "\(offsetSliderValueGift, specifier: "%.0f")"
                                    } else if activeSticker == .memoji {
                                        return "\(offsetSliderValueMemoji, specifier: "%.0f")"
                                    } else if activeSticker == .swiftui {
                                        return "\(offsetSliderValueSwiftui, specifier: "%.0f")"
                                    } else if activeSticker == .bunny {
                                        return "\(offsetSliderValueBunny, specifier: "%.0f")"
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
                                            switch activeSticker {
                                            case .xcode:
                                                return offsetSliderValueXcode
                                            case .hello:
                                                return offsetSliderValueHello
                                            case .swift:
                                                return offsetSliderValueSwift
                                            case .gift:
                                                return offsetSliderValueGift
                                            case .memoji:
                                                return offsetSliderValueMemoji
                                            case .swiftui:
                                                return offsetSliderValueSwiftui
                                            case .bunny:
                                                return offsetSliderValueBunny
                                            }
                                        }
                                        return 0 // Default value
                                    },
                                    set: { newValue in
                                        if let activeSticker = activeSticker {
                                            switch activeSticker {
                                            case .xcode:
                                                offsetSliderValueXcode = newValue
                                            case .hello:
                                                offsetSliderValueHello = newValue
                                            case .swift:
                                                offsetSliderValueSwift = newValue
                                            case .gift:
                                                offsetSliderValueGift = newValue
                                            case .memoji:
                                                offsetSliderValueMemoji = newValue
                                            case .swiftui:
                                                offsetSliderValueSwiftui = newValue
                                            case .bunny:
                                                offsetSliderValueBunny = newValue
                                            }
                                        }
                                    }
                                ),
                                in: 0...100,
                                step: 1
                            )
                            .onChange(of: offsetSliderValueXcode + offsetSliderValueHello + offsetSliderValueSwift + offsetSliderValueGift + offsetSliderValueMemoji + offsetSliderValueSwiftui + offsetSliderValueBunny) {
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
            
            // Main Interface
            ZStack {
                XcodeStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex, resetStickerOffset: $resetStickerOffset, xAxisSliderValue: $xAxisSliderValueXcode, zAxisSliderValue: $zAxisSliderValueXcode, offsetSliderValue: $offsetSliderValueXcode, activeSticker: $activeSticker)
                    .offset(x: -140, y: 180)
                    .scaleEffect(viewVisible ? 1 : 2)
                    .rotationEffect(Angle(degrees: activeSticker == .xcode ? 0 : 10))
                    .blur(radius: viewVisible ? 0.0 : 30.0)
                    .opacity(viewVisible ? 1.0 : 0.0)
                    .animation(.spring().delay(0.6), value: viewVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.triggerSensoryFeedback += 1
                                }
                            }
                    .sensoryFeedback(.impact(weight: .heavy), trigger: triggerSensoryFeedback)
                    .zIndex(Double(zIndexMap[.xcode] ?? 0))


                HelloStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex, resetStickerOffset: $resetStickerOffset, xAxisSliderValue: $xAxisSliderValueHello, zAxisSliderValue: $zAxisSliderValueHello, offsetSliderValue: $offsetSliderValueHello, activeSticker: $activeSticker)
                    .offset(x: 0, y: -30)
                    .rotationEffect(Angle(degrees: activeSticker == .hello ? 0 : -2))
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
                    .zIndex(Double(zIndexMap[.hello] ?? 0))
                
                SwiftStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex, resetStickerOffset: $resetStickerOffset, xAxisSliderValue: $xAxisSliderValueSwift, zAxisSliderValue: $zAxisSliderValueSwift, offsetSliderValue: $offsetSliderValueSwift, activeSticker: $activeSticker)
                    .offset(x: 30, y: -310)
                    .rotationEffect(Angle(degrees: activeSticker == .swift ? 0 : -2))
                    .scaleEffect(viewVisible ? 1 : 2)
                    .blur(radius: viewVisible ? 0.0 : 30.0)
                    .opacity(viewVisible ? 1.0 : 0.0)
                    .animation(.spring().delay(0.2), value: viewVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                self.triggerSensoryFeedback += 1
                                }
                            }
                    .sensoryFeedback(.impact(weight: .heavy), trigger: triggerSensoryFeedback)
                    .zIndex(Double(zIndexMap[.swift] ?? 0))
                
                GiftStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex, resetStickerOffset: $resetStickerOffset, xAxisSliderValue: $xAxisSliderValueGift, zAxisSliderValue: $zAxisSliderValueGift, offsetSliderValue: $offsetSliderValueGift, activeSticker: $activeSticker)
                    .offset(x: -168, y: -185)
                    .rotationEffect(Angle(degrees: activeSticker == .gift ? 0 : 12))
                    .scaleEffect(viewVisible ? 1 : 2)
                    .blur(radius: viewVisible ? 0.0 : 30.0)
                    .opacity(viewVisible ? 1.0 : 0.0)
                    .animation(.spring().delay(0.1), value: viewVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.triggerSensoryFeedback += 1
                                }
                            }
                    .sensoryFeedback(.impact(weight: .heavy), trigger: triggerSensoryFeedback)
                    .zIndex(Double(zIndexMap[.gift] ?? 0))
                
                MemojiStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex, resetStickerOffset: $resetStickerOffset, xAxisSliderValue: $xAxisSliderValueMemoji, zAxisSliderValue: $zAxisSliderValueMemoji, offsetSliderValue: $offsetSliderValueMemoji, activeSticker: $activeSticker)
                    .offset(x: 80, y: -182)
                    .rotationEffect(Angle(degrees: activeSticker == .memoji ? 0 : 17))
                    .scaleEffect(viewVisible ? 1 : 2)
                    .blur(radius: viewVisible ? 0.0 : 30.0)
                    .opacity(viewVisible ? 1.0 : 0.0)
                    .animation(.spring().delay(0.3), value: viewVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                self.triggerSensoryFeedback += 1
                                }
                            }
                    .sensoryFeedback(.impact(weight: .heavy), trigger: triggerSensoryFeedback)
                    .zIndex(Double(zIndexMap[.memoji] ?? 0))
                
                SwiftUIStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex, resetStickerOffset: $resetStickerOffset, xAxisSliderValue: $xAxisSliderValueSwiftui, zAxisSliderValue: $zAxisSliderValueSwiftui, offsetSliderValue: $offsetSliderValueSwiftui, activeSticker: $activeSticker)
                    .offset(x: 156, y: 132)
                    .rotationEffect(Angle(degrees: activeSticker == .swiftui ? 0 : -4))
                    .scaleEffect(viewVisible ? 1 : 2)
                    .blur(radius: viewVisible ? 0.0 : 30.0)
                    .opacity(viewVisible ? 1.0 : 0.0)
                    .animation(.spring().delay(0.4), value: viewVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                self.triggerSensoryFeedback += 1
                                }
                            }
                    .sensoryFeedback(.impact(weight: .heavy), trigger: triggerSensoryFeedback)
                    .zIndex(Double(zIndexMap[.swiftui] ?? 0))
                
                BunnyStickerView(zIndexMap: $zIndexMap, nextZIndex: $nextZIndex, resetStickerOffset: $resetStickerOffset, xAxisSliderValue: $xAxisSliderValueBunny, zAxisSliderValue: $zAxisSliderValueBunny, offsetSliderValue: $offsetSliderValueBunny, activeSticker: $activeSticker)
                    .offset(x: 155, y: 250)
                    .rotationEffect(Angle(degrees: activeSticker == .bunny ? 0 : 20))
                    .scaleEffect(viewVisible ? 1 : 2)
                    .blur(radius: viewVisible ? 0.0 : 30.0)
                    .opacity(viewVisible ? 1.0 : 0.0)
                    .animation(.spring().delay(0.5), value: viewVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                self.triggerSensoryFeedback += 1
                                }
                            }
                    .sensoryFeedback(.impact(weight: .heavy), trigger: triggerSensoryFeedback)
                    .zIndex(Double(zIndexMap[.bunny] ?? 0))
                
            }
            .ignoresSafeArea()
            .onAppear{
                viewVisible.toggle()
            }
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
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
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

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
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
    case xcode, hello, swift, gift, memoji, swiftui, bunny
}

#Preview {
    StickerWallView()
}
    
