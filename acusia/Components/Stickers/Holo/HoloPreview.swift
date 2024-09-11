//
//  HoloPreview.swift
//  acusia
//
//  Created by decoherence on 9/9/24.
//
import MetalKit
import SwiftUI

struct IridescentUniforms {
    var modelMatrix: simd_float4x4
    var viewProjectionMatrix: simd_float4x4
    var lightDirection: simd_float3
    var padding: Float = 0  // Add this padding
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
        mtkView.device = MTLCreateSystemDefaultDevice()
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
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var time: Float = 0
        var vertexBuffer: MTLBuffer!
        var indexBuffer: MTLBuffer!
        var uniformBuffer: MTLBuffer!
        var rampTexture: MTLTexture!
        var noiseTexture: MTLTexture!
        var currentRotationAngleX: Double = 0
        var currentRotationAngleY: Double = 0
        var targetRotationAngleX: Double = 0
        var targetRotationAngleY: Double = 0

        init(_ parent: MetalCardView) {
            self.parent = parent
            super.init()

            guard let device = MTLCreateSystemDefaultDevice() else {
                print("Metal is not supported on this device")
                return
            }
            self.device = device

            do {
                let library = device.makeDefaultLibrary()
                let vertexFunction = library?.makeFunction(name: "vertex_main")
                let fragmentFunction = library?.makeFunction(name: "fragment_main")

                let vertexDescriptor = MTLVertexDescriptor()
                vertexDescriptor.attributes[0].format = .float3
                vertexDescriptor.attributes[0].offset = 0
                vertexDescriptor.attributes[0].bufferIndex = 0
                vertexDescriptor.attributes[1].format = .float2
                vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 3
                vertexDescriptor.attributes[1].bufferIndex = 0
                vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 5

                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                pipelineDescriptor.vertexFunction = vertexFunction
                pipelineDescriptor.fragmentFunction = fragmentFunction
                pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
                pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
                pipelineDescriptor.vertexDescriptor = vertexDescriptor

                self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
                self.commandQueue = device.makeCommandQueue()

                let vertexData: [Float] = [
                    -1.0, -1.0, 0.0, 0.0, 1.0,
                    1.0, -1.0, 0.0, 1.0, 1.0,
                    -1.0, 1.0, 0.0, 0.0, 0.0,
                    1.0, 1.0, 0.0, 1.0, 0.0
                ]
                self.vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: [])

                let indexData: [UInt16] = [0, 1, 2, 2, 1, 3]
                self.indexBuffer = device.makeBuffer(bytes: indexData, length: indexData.count * MemoryLayout<UInt16>.size, options: [])

                self.uniformBuffer = device.makeBuffer(length: MemoryLayout<IridescentUniforms>.size, options: [])

                // Load ramp texture
                let textureLoader = MTKTextureLoader(device: device)
                let options: [MTKTextureLoader.Option: Any] = [
                    .SRGB: false // Fixes saturation from color ramp.
                ]
                self.rampTexture = try textureLoader.newTexture(name: "ramp", scaleFactor: 1.0, bundle: nil, options: options)
                self.noiseTexture = try textureLoader.newTexture(name: "noise", scaleFactor: 1.0, bundle: nil, options: nil)
            } catch {
                print("Failed to create pipeline state, buffers, or textures: \(error.localizedDescription)")
            }
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else {
                return
            }

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

            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentTexture(rampTexture, index: 0)
            renderEncoder.setFragmentTexture(noiseTexture, index: 1)
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
            renderEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

struct HoloPreview: View {
    @State private var rotationAngleX: Double = 0
    @State private var rotationAngleY: Double = 0

    var body: some View {
        VStack {
            ZStack {
                // Metal shader view with circular mask
                MetalCardView(rotationAngleX: $rotationAngleX, rotationAngleY: $rotationAngleY)
                    .frame(width: 400, height: 400)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            .rotation3DEffect(
                .degrees(rotationAngleX),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(rotationAngleY),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        rotationAngleX = Double(-value.translation.height / 20)
                        rotationAngleY = Double(value.translation.width / 20)
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            rotationAngleX = 0
                            rotationAngleY = 0
                        }
                    }
            )
        }
    }
}

struct SoundScreen_Previews: PreviewProvider {
    static var previews: some View {
        HoloPreview()
            .background(Color.black)
    }
}
