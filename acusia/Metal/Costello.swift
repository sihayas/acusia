import SwiftUI
import MetalKit

struct Uniforms {
    var time: Float
    var resolution: SIMD2<Float>
    var uniqueTopLeftInput: UInt32
    var uniqueTopRightInput: UInt32
    var uniqueBottomRightInput: UInt32
    var topLeftThickness: Float
    var topRightThickness: Float
    var bottomRightThickness: Float
    var animationProgress: Float
}

struct MetalView: UIViewRepresentable {
    @Binding var time: Float
    @Binding var uniqueBottomRightInput: UInt32
    @Binding var uniqueTopRightInput: UInt32
    @Binding var uniqueTopLeftInput: UInt32
    @Binding var topLeftThickness: Float
    @Binding var topRightThickness: Float
    @Binding var bottomRightThickness: Float
    @Binding var animationProgress: Float
    
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.autoResizeDrawable = true
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
         context.coordinator.time = time
         context.coordinator.resolution = SIMD2<Float>(Float(uiView.drawableSize.width), Float(uiView.drawableSize.height))
         context.coordinator.uniqueBottomRightInput = uniqueBottomRightInput
         context.coordinator.uniqueTopRightInput = uniqueTopRightInput
         context.coordinator.uniqueTopLeftInput = uniqueTopLeftInput
         context.coordinator.topLeftThickness = topLeftThickness
         context.coordinator.topRightThickness = topRightThickness
         context.coordinator.bottomRightThickness = bottomRightThickness
         context.coordinator.animationProgress = animationProgress
         uiView.setNeedsDisplay()
     }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipeline: MTLComputePipelineState!
        
        var time: Float = 0
        var uniqueBottomRightInput: UInt32 = 0
        var uniqueTopRightInput: UInt32 = 0
        var uniqueTopLeftInput: UInt32 = 0
        var topLeftThickness: Float = 0
        var topRightThickness: Float = 0
        var bottomRightThickness: Float = 0
        
        var resolution: SIMD2<Float> = SIMD2<Float>(0, 0)
        var animationProgress: Float = 0
        
        init(_ parent: MetalView) {
            self.parent = parent
            super.init()
            
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.device = metalDevice
            }
            
            self.commandQueue = device.makeCommandQueue()!
            
            let defaultLibrary = device.makeDefaultLibrary()!
            let kernelFunction = defaultLibrary.makeFunction(name: "mainImage")
            
            do {
                pipeline = try device.makeComputePipelineState(function: kernelFunction!)
            } catch {
                fatalError("Failed to create pipeline state: \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
                return
            }
            
            resolution = SIMD2<Float>(Float(drawable.texture.width), Float(drawable.texture.height))
            
            var uniforms = Uniforms(
                time: time,
                resolution: resolution,
                uniqueTopLeftInput: uniqueTopLeftInput,
                uniqueTopRightInput: uniqueTopRightInput,
                uniqueBottomRightInput: uniqueBottomRightInput,
                topLeftThickness: topLeftThickness,
                topRightThickness: topRightThickness,
                bottomRightThickness: bottomRightThickness,
                animationProgress: animationProgress
            )
            
            computeEncoder.setBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
            computeEncoder.setComputePipelineState(pipeline)
            computeEncoder.setTexture(drawable.texture, index: 0)
            
            let threadGroupSize = MTLSizeMake(8, 8, 1)
            let threadGroups = MTLSizeMake(
                drawable.texture.width / threadGroupSize.width,
                drawable.texture.height / threadGroupSize.height,
                1)
            
            computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
            computeEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

struct ShaderView: View {
    @State private var uniqueTopLeftInput: Double = 0
    @State private var uniqueTopRightInput: Double = 0
    @State private var uniqueBottomRightInput: Double = 0
    @State private var topLeftThickness: Float = 900.0
    @State private var topRightThickness: Float = 1800.0
    @State private var bottomRightThickness: Float = 2700.0
    @State private var time: Float = 0
    @State private var animationProgress: Float = 0

    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            MetalView(time: $time,
                      uniqueBottomRightInput: Binding(
                        get: { UInt32(self.uniqueBottomRightInput) },
                        set: { self.uniqueBottomRightInput = Double($0) }
                      ),
                      uniqueTopRightInput: Binding(
                        get: { UInt32(self.uniqueTopRightInput) },
                        set: { self.uniqueTopRightInput = Double($0) }
                      ),
                      uniqueTopLeftInput: Binding(
                        get: { UInt32(self.uniqueTopLeftInput) },
                        set: { self.uniqueTopLeftInput = Double($0) }
                      ),
                      topLeftThickness: Binding(
                        get: { self.topLeftThickness },
                        set: { self.topLeftThickness = $0 }
                      ),
                      topRightThickness: Binding(
                        get: { self.topRightThickness },
                        set: { self.topRightThickness = $0 }
                      ),
                      bottomRightThickness: Binding(
                        get: { self.bottomRightThickness },
                        set: { self.bottomRightThickness = $0 }
                      ),
                      animationProgress: $animationProgress
            )
                .aspectRatio(contentMode: .fit)
            
            Slider(value: $uniqueTopLeftInput, in: 0...1000000)
            Slider(value: $uniqueTopRightInput, in: 0...1000000)
            Slider(value: $uniqueBottomRightInput, in: 0...1000000)
            Slider(value: $topLeftThickness, in: 0...3000)
            Slider(value: $topRightThickness, in: 0...3000)
            Slider(value: $bottomRightThickness, in: 0...3000)
        }
        .onReceive(timer) { _ in
            time += 1/60
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShaderView()
            .background(Color.black)
    }
}
