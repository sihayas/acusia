//
//  HoloPreview.swift
//  acusia
//
//  Created by decoherence on 9/9/24.
//
import CoreMotion
import SwiftUI


#Preview {
    HoloPreview()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
}

struct HoloPreview: View {
    private let motionManager = CMMotionManager()
    
    // Baseline for pitch and roll
    @State private var pitchBaseline: Double = 30
    @State private var rollBaseline: Double = 0
    
    var body: some View {
        let mkShape = MKSymbolShape(imageName: "helloSticker")
        let mkShape2 = MKSymbolShape(imageName: "bunnySticker")
        
        VStack {
            ZStack {
                mkShape
                    .stroke(.white,
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round,
                                lineJoin: .round
                            ))
                    .fill(.white)
                    .frame(width: 340, height: 112)
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 0)
                
                Image("helloSticker")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 340, height: 112)
                    .aspectRatio(contentMode: .fill)
                
                // Metal shader view with circular mask
                HoloShaderView()
                    .frame(width: 348, height: 348)
                    .mask(
                        mkShape
                            .stroke(.white,
                                    style: StrokeStyle(
                                        lineWidth: 8,
                                        lineCap: .round,
                                        lineJoin: .round
                                    ))
                            .fill(.white)
                            .frame(width: 340, height: 112)
                    )
                    .blendMode(.screen)
                    .opacity(1.0)
            }
            
            // ZStack {
            //     mkShape2
            //         .stroke(.white,
            //                 style: StrokeStyle(
            //                     lineWidth: 8,
            //                     lineCap: .round,
            //                     lineJoin: .round
            //                 ))
            //         .fill(.white)
            //         .frame(width: 90, height: 110)
            //     
            //     Image("bunnySticker")
            //         .resizable()
            //         .scaledToFill()
            //         .frame(width: 90, height: 110)
            //         .aspectRatio(contentMode: .fill)
            //     
            //     // Metal shader view with circular mask
            //     HoloShaderView()
            //         .frame(width: 98, height: 118)
            //         .mask(
            //             mkShape2
            //                 .stroke(.white,
            //                         style: StrokeStyle(
            //                             lineWidth: 8,
            //                             lineCap: .round,
            //                             lineJoin: .round
            //                         ))
            //                 .fill(.white)
            //                 .frame(width: 90, height: 110)
            //         )
            //         .blendMode(.screen)
            // }
            
            
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    HoloRotationManager.shared.rotationAngleX = Float(-value.translation.height / 20)
                    HoloRotationManager.shared.rotationAngleY = Float(value.translation.width / 20)
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        HoloRotationManager.shared.rotationAngleX = 30
                        HoloRotationManager.shared.rotationAngleY = 0
                    }
                }
        )
        .onAppear {
            startDeviceMotionUpdates()
        }
    }
    
    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            
            motionManager.startDeviceMotionUpdates(to: .main) { motionData, _ in
                guard let motion = motionData else { return }
                
                let pitch = motion.attitude.pitch * 180 / .pi
                
                // Adjust pitch based on baseline
                var adjustedPitch = pitch - pitchBaseline
                
                // Shader progression: map pitch to -15 to 75 range
                if adjustedPitch <= -45 {
                    // Rebase if pitch exceeds lower limit
                    pitchBaseline = pitch
                    adjustedPitch = 30 // Reset shader progression to middle
                } else if adjustedPitch >= 45 {
                    // Rebase if pitch exceeds upper limit
                    pitchBaseline = pitch
                    adjustedPitch = 30 // Reset shader progression to middle
                }
                
                // Ensure shader progression stays within the -15 to 75 range
                let shaderValue = clamp(30 + adjustedPitch, -15, 75)
                
                // Apply shader value to rotationAngleX via the manager
                HoloRotationManager.shared.rotationAngleX = Float(shaderValue)
            }
        }
    }
    
    // Helper function to clamp values
    func clamp(_ value: Double, _ minValue: Double, _ maxValue: Double) -> Double {
        return min(max(value, minValue), maxValue)
    }
}
