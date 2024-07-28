import SwiftUI
import MetalKit
import SceneKit
import SceneKit.ModelIO
import SpriteKit


struct FragmentUniforms {
    var cameraPosition: SIMD3<Float>
    var baseColor: SIMD3<Float>
    var roughness: Float
    var iridescenceFactor: Float
    var iridescenceIor: Float
    var iridescenceThicknessMin: Float
    var iridescenceThicknessMax: Float
}


struct SoundScreen: View {
    let sound: APIAppleSoundData
    
    @State private var scene: SCNScene?
    @State private var ellipsoidNode: SCNNode?
    @State private var isReversing = true
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let scene = scene {
                SceneView(
                    scene: scene,
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
            } else {
                ProgressView()
            }
            
            Button {
                self.scene = createScene()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .onAppear(perform: setupScene)
    }
    
    private func setupScene() {
        self.scene = createScene()
    }
}



func createTextImage(text: String, size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    let img = renderer.image { ctx in
        // Set clear background
        ctx.cgContext.setFillColor(UIColor.clear.cgColor)
        ctx.fill(CGRect(origin: .zero, size: size))

        // Configure text attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size.height / 5),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ]

        // Calculate text size
        let textSize = (text as NSString).size(withAttributes: attrs)
        let textRect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)

        // Draw the text
        (text as NSString).draw(in: textRect, withAttributes: attrs)
    }

    return img
}


extension SoundScreen {
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black

        let discDiameter: CGFloat = 4
        let discThickness: CGFloat = 0.8

        let allocator = MTKMeshBufferAllocator(device: MTLCreateSystemDefaultDevice()!)
        let disc = MDLMesh.newEllipsoid(
            withRadii: vector_float3(Float(discDiameter/2), Float(discDiameter/2), Float(discThickness/2)),
            radialSegments: 64,
            verticalSegments: 64,
            geometryType: .triangles,
            inwardNormals: false,
            hemisphere: false,
            allocator: allocator
        )

        let discGeometry = SCNGeometry(mdlMesh: disc)
        
        // Generate the dynamic text image
        let textImage = createTextImage(text: "Hello, World", size: CGSize(width: 512, height: 512))

        // Create material with texture
        let material = createIridescentMaterial()
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = textImage
        textMaterial.isDoubleSided = true // Ensure the texture is visible from both sides

        discGeometry.materials = [material, textMaterial]

        let ellipsoidNode = SCNNode(geometry: discGeometry)

        let ellipsoidParentNode = SCNNode()
        ellipsoidParentNode.addChildNode(ellipsoidNode)

        // Camera setup
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 18)
        cameraNode.camera!.fieldOfView = 30
        cameraNode.camera!.zNear = 1
        cameraNode.camera!.zFar = 100
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(ellipsoidParentNode)

        ellipsoidParentNode.scale = SCNVector3(1.0, 1.0, 1.0)
        ellipsoidParentNode.position = SCNVector3(0, 0, 0)
        ellipsoidParentNode.eulerAngles.y = Float.pi * 0.2

        playAnimationSequence(ellipsoidNode: ellipsoidParentNode, isReversing: isReversing)

        return scene
    }
    
    private func createIridescentMaterial() -> SCNMaterial {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            fatalError("Failed to create Metal device, default library, or shader functions")
        }

        let material = SCNMaterial()

        // Create a custom SCNProgram
        let program = SCNProgram()
        program.vertexFunctionName = "vertexShader"
        program.fragmentFunctionName = "fragmentShader"



        // Apply the program to the material
        material.program = program

        // Create and set uniform buffer
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<FragmentUniforms>.stride, options: [])!
        var uniforms = FragmentUniforms(
            cameraPosition: SIMD3<Float>(0, 0, 0),
            baseColor: SIMD3<Float>(1.0, 1.0, 1.0),
            roughness: 0.1,
            iridescenceFactor: 1.0, // 0.0 - 1.0 Iridescent effect strength
            iridescenceIor: 1.35,  // 1.0 - 2.5 Iridescence pronunciation at different angles
            iridescenceThicknessMin: 100.0, // The higher minimum (100 nm) moves away from the blue region.
            iridescenceThicknessMax: 400.0
        )
        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<FragmentUniforms>.stride)

        // Set uniform buffer on the material
        material.setValue(uniformBuffer, forKey: "uniforms")
        
        return material
    }

}


// MARK: - Animation Helpers
extension SoundScreen {
    func playAnimationSequence(ellipsoidNode: SCNNode, isReversing: Bool) {
        playForwardAnimation(ellipsoidNode: ellipsoidNode)
    }
    
    private func playForwardAnimation(ellipsoidNode: SCNNode) {
        let animateCombined = SCNAction.customAction(duration: 1.5) { node, elapsedTime in
            let progress = Float(elapsedTime) / 1.5
            let easeProgress = self.customEaseOut(progress)
            
            // Scale and move normally
            let scale = 0.0 + (1 - 0.0) * easeProgress
            node.scale = SCNVector3(scale, scale, scale)
            node.position.x = 2.5 * (1 - easeProgress)
            node.position.y = 3 * (1 - easeProgress)
            
            // Rotation with independent control
            let rotationProgress = Float(elapsedTime) / 1.0
            let easedRotationProgress = self.customRotationEaseOut(min(rotationProgress, 1))
            let initialTilt = Float.pi * 0.2  // Initial tilt (36 degrees)
            let additionalRotation = Float.pi * 0.001  // Additional 72 degrees
            let totalRotation = initialTilt + additionalRotation
            let rotation = initialTilt - easedRotationProgress * totalRotation
            
            node.eulerAngles.y = rotation
        }
        
        let sequence = SCNAction.sequence([animateCombined])
        
        ellipsoidNode.removeAllActions()
        ellipsoidNode.runAction(sequence)
    }
    
    // Rapid ease out for scaling and translating in
    private func customEaseOut(_ t: Float) -> Float {
        return 1 - pow(1 - t, 5)  // Increased power for faster initial movement
    }

    private func customRotationEaseOut(_ t: Float) -> Float {
        // Start slow, accelerate in the middle, then slow down at the end
        if t < 0.5 {
            // Slow start (ease-in)
            return 2 * t * t
        } else {
            // Slow end (ease-out)
            return 1 - pow(-2 * t + 2, 2) / 2
        }
    }
}
