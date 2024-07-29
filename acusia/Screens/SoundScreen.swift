import SwiftUI
import RealityKit
import ARKit
import Metal

struct SwiftIridescenceUniforms {
    var baseColor: SIMD3<Float>
    var cameraPosition: SIMD3<Float>
    var roughness: Float
    var iridescenceFactor: Float
    var iridescenceIor: Float
    var iridescenceThicknessMin: Float
    var iridescenceThicknessMax: Float
}

struct SoundScreen: View {
    let sound: APIAppleSoundData
    
    var body: some View {
        ARViewContainer(sound: sound)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    let sound: APIAppleSoundData
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        setupARView(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func setupARView(_ arView: ARView) {
        let customMaterial = createIridescentMaterial()
        let mesh = MeshResource.generateSphere(radius: 0.5)
        let modelEntity = ModelEntity(mesh: mesh, materials: [customMaterial])
        
        let sphereAnchor = AnchorEntity(world: SIMD3<Float>(0, 0, -0.5))
        
        sphereAnchor.addChild(modelEntity)
        
        let animationDefinition = FromToByAnimation(to: Transform(rotation: simd_quatf(angle: .pi, axis: [0, 1, 0])),
                                                    duration: 10.0,
            bindTarget: .transform)
        let animationResource = try! AnimationResource.generate(with: animationDefinition)
        modelEntity.playAnimation(animationResource)
        arView.scene.anchors.append(sphereAnchor)
    }
    
    private func createIridescentMaterial() -> CustomMaterial {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary() else {
            fatalError("Failed to create Metal device or default library")
        }
        
        let surfaceShader = CustomMaterial.SurfaceShader(named: "iridescenceShader",
                                                         in: library)
        var customMaterial = try! CustomMaterial(surfaceShader: surfaceShader, lightingModel: .lit)
        
        customMaterial.withMutableUniforms(ofType: SwiftIridescenceUniforms.self, stage: .surfaceShader) { uniforms, resources in
            uniforms.baseColor = SIMD3<Float>(1.0, 1.0, 1.0)
            uniforms.cameraPosition = SIMD3<Float>(0, 0, 0)
            uniforms.roughness = 0.1
            uniforms.iridescenceFactor = 1.0
            uniforms.iridescenceIor = 1.35
            uniforms.iridescenceThicknessMin = 100.0
            uniforms.iridescenceThicknessMax = 400.0
        }
        
        return customMaterial
    }
}
