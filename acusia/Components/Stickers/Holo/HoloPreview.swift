//
//  HoloPreview.swift
//  acusia
//
//  Created by decoherence on 9/9/24.
//
import CoreMotion
import MetalKit
import SwiftUI

struct IridescentUniforms {
    var modelMatrix: simd_float4x4
    var viewProjectionMatrix: simd_float4x4
    var lightDirection: simd_float3
    var padding: Float = 0
    var rotationAngleX: Float
    var rotationAngleY: Float
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
        mtkView.preferredFramesPerSecond = 120
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
        var currentRotationAngleX: Double = 0
        var currentRotationAngleY: Double = 0
        var targetRotationAngleX: Double = 0
        var targetRotationAngleY: Double = 0
        var uniformBuffer: MTLBuffer!

        init(_ parent: MetalCardView) {
            self.parent = parent
            super.init()

            // Create uniform buffer
            self.uniformBuffer = MetalResourceManager.shared.device.makeBuffer(length: MemoryLayout<IridescentUniforms>.stride, options: [])
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = MetalResourceManager.shared.commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else { return }

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
                rotationAngleY: Float(currentRotationAngleY)
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
    private let motionManager = CMMotionManager()

    // Range -15 to 75 (Complete-Start)
    @State private var rotationAngleX: Double = 30
    @State private var rotationAngleY: Double = 0

    // Baseline for pitch, middle of shader range
    @State private var pitchBaseline: Double = 30
    // Baseline for roll
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
                            .fill(.white)
                            .frame(width: 170, height: 56)
                    )
                    .blendMode(.screen)
                    .opacity(1.0)
            }

            ZStack {
                mkShape2
                    .stroke(.white,
                            style: StrokeStyle(
                                lineWidth: 8,
                                lineCap: .round,
                                lineJoin: .round
                            ))
                    .fill(.white)
                    .frame(width: 90, height: 110)

                Image("bunnySticker")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 110)
                    .aspectRatio(contentMode: .fill)

                // Metal shader view with circular mask
                MetalCardView(rotationAngleX: $rotationAngleX, rotationAngleY: $rotationAngleY)
                    .frame(width: 98, height: 118)
                    .mask(
                        mkShape2
                            .stroke(.white,
                                    style: StrokeStyle(
                                        lineWidth: 8,
                                        lineCap: .round,
                                        lineJoin: .round
                                    ))
                            .fill(.white)
                            .frame(width: 90, height: 110)
                    )
                    .blendMode(.screen)
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
                        rotationAngleX = 30
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
            motionManager.deviceMotionUpdateInterval = 0.01

            motionManager.startDeviceMotionUpdates(to: .main) { motionData, _ in
                guard let motion = motionData else { return }

                let pitch = motion.attitude.pitch * 180 / .pi

                // Adjust pitch based on baseline
                var adjustedPitch = pitch - pitchBaseline

                // Shader progression: map pitch to -15 to 75 range
                if adjustedPitch <= -45 { // New wider range
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

                // Apply shader value to rotationAngleX

                rotationAngleX = shaderValue
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
