//
//  HoloShaderView.swift
//  acusia
//
//  Created by decoherence on 9/12/24.
//
import MetalKit
import SwiftUI

struct HoloUniforms {
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

        init(_ parent: MetalCardView) {
            self.parent = parent
            super.init()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = MetalResourceManager.shared.commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else { return }

            // Update rotation angles
            currentRotationAngleX += (targetRotationAngleX - currentRotationAngleX)
            currentRotationAngleY += (targetRotationAngleY - currentRotationAngleY)

            // Update the shared uniform buffer
            MetalResourceManager.shared.updateUniformBuffer(rotationX: Float(currentRotationAngleX), rotationY: Float(currentRotationAngleY))

            // Use the shared uniform buffer
            renderEncoder.setRenderPipelineState(MetalResourceManager.shared.pipelineState)
            renderEncoder.setVertexBuffer(MetalResourceManager.shared.vertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(MetalResourceManager.shared.uniformBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(MetalResourceManager.shared.uniformBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentTexture(MetalResourceManager.shared.rampTexture, index: 0)
            renderEncoder.setFragmentTexture(MetalResourceManager.shared.noiseTexture, index: 1)
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: MetalResourceManager.shared.indexBuffer, indexBufferOffset: 0)
            renderEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
