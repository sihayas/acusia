//
//  HoloPreview.swift
//  acusia
//
//  Created by decoherence on 9/9/24.
//
import MetalKit
import SwiftUI
import CoreMotion

struct IridescentUniforms {
    var modelMatrix: simd_float4x4
    var viewProjectionMatrix: simd_float4x4
    var lightDirection: simd_float3
    var padding: Float = 0
    var rotationAngleX: Float
    var rotationAngleY: Float
    var time: Float
}

struct MetalCardView: UIViewRepresentable {
    @Binding var rotationAngleX: Double
    @Binding var rotationAngleY: Double

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MetalResourceManager.shared.device
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.depthStencilPixelFormat = .depth32Float
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.targetRotationAngleX = rotationAngleX
        context.coordinator.targetRotationAngleY = rotationAngleY
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalCardView
        var time: Float = 0
        var currentRotationAngleX: Double = 0
        var currentRotationAngleY: Double = 0
        var targetRotationAngleX: Double = 0
        var targetRotationAngleY: Double = 0
        var uniformBuffer: MTLBuffer!

        init(_ parent: MetalCardView) {
            self.parent = parent
            super.init()
            
            // Create uniform buffer
            self.uniformBuffer = MetalResourceManager.shared.device.makeBuffer(length: MemoryLayout<IridescentUniforms>.size, options: [])
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = MetalResourceManager.shared.commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else { return }

            time += 1 / Float(view.preferredFramesPerSecond)

            // Animate rotation angles
            let animationSpeed = 0.05
            currentRotationAngleX += (targetRotationAngleX - currentRotationAngleX) * animationSpeed
            currentRotationAngleY += (targetRotationAngleY - currentRotationAngleY) * animationSpeed

            // Update uniform buffer
            var uniforms = IridescentUniforms(
                modelMatrix: matrix_identity_float4x4,
                viewProjectionMatrix: matrix_identity_float4x4,
                lightDirection: simd_normalize(simd_float3(1, 1, -1)),
                rotationAngleX: Float(currentRotationAngleX),
                rotationAngleY: Float(currentRotationAngleY),
                time: time
            )
            uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<IridescentUniforms>.size)

            renderEncoder.setRenderPipelineState(MetalResourceManager.shared.pipelineState)
            renderEncoder.setVertexBuffer(MetalResourceManager.shared.vertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentTexture(MetalResourceManager.shared.rampTexture, index: 0)
            renderEncoder.setFragmentTexture(MetalResourceManager.shared.noiseTexture, index: 1)
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: MetalResourceManager.shared.indexBuffer, indexBufferOffset: 0)
            renderEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

struct HoloShaderPreview: View {
    @State private var rotationAngleX: Double = 1.75 // -5 is end of, 5 is beginning
    @State private var rotationAngleY: Double = 0
    private let motionManager = CMMotionManager()
    
    @State private var pitchBaseline: Double = 0 // Baseline for pitch
    @State private var rollBaseline: Double = 0  // Baseline for roll

    var body: some View {
        let mkShape = MKSymbolShape(imageName: "helloSticker")

        VStack {
            ZStack {
                mkShape
                    .stroke(.white,
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round, // This makes the stroke ends rounded
                                lineJoin: .round // This makes the stroke joins rounded
                            ))
                    .frame(width: 170, height: 56)

                Image("helloSticker")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 56)
                    .aspectRatio(contentMode: .fill)

                // Metal shader view with circular mask
                MetalCardView(rotationAngleX: $rotationAngleX, rotationAngleY: $rotationAngleY)
                    .frame(width: 178, height: 178)
                    .mask(
                        mkShape
                            .stroke(.white,
                                    style: StrokeStyle(
                                        lineWidth: 8,
                                        lineCap: .round,
                                        lineJoin: .round
                                    ))
                            .frame(width: 170, height: 56)
                    )
                    .blendMode(.screen)
                    .opacity(1.0)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    rotationAngleX = Double(-value.translation.height / 20)
                    rotationAngleY = Double(value.translation.width / 20)
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        rotationAngleX = 1.75
                        rotationAngleY = 0
                    }
                }
        )
        .onAppear {
            startDeviceMotionUpdates()
        }
    }

    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            // Adjust the update interval to reduce CPU load
            motionManager.deviceMotionUpdateInterval = 0.1
            
            motionManager.startDeviceMotionUpdates(to: .main) { motionData, error in
                guard let motion = motionData else { return }

                // Get pitch and roll from device motion
                let pitch = motion.attitude.pitch * 180 / .pi
                let roll = motion.attitude.roll * 180 / .pi

                // Calculate adjusted pitch and roll based on the baseline
                var adjustedPitch = (pitch - pitchBaseline) / 10
                var adjustedRoll = (roll - rollBaseline) / 10

                // Clamp values between -5 and 5
                adjustedPitch = clamp(adjustedPitch, -5, 5)
                adjustedRoll = clamp(adjustedRoll, -5, 5)

                // Rebase: If we hit the max/min, reset and treat it as the new baseline
                if adjustedPitch == -5 || adjustedPitch == 5 {
                    pitchBaseline = pitch // Reset baseline to current pitch
                    adjustedPitch = 1.75  // Reset rotationAngleX to initial value
                }

                if adjustedRoll == -5 || adjustedRoll == 5 {
                    rollBaseline = roll // Reset baseline to current roll
                    adjustedRoll = 0     // Reset rotationAngleY to initial value
                }

                // Apply with smooth animation
                withAnimation(.easeInOut(duration: 0.1)) { // Slightly longer animation duration
                    rotationAngleX = adjustedPitch
                    rotationAngleY = adjustedRoll
                }
            }
        }
    }
      
      // Helper function to clamp values
      func clamp(_ value: Double, _ minValue: Double, _ maxValue: Double) -> Double {
          return min(max(value, minValue), maxValue)
      }
}

#Preview {
    HoloShaderPreview()
        .background(Color.black)
}
