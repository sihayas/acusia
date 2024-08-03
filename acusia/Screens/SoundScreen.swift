import SwiftUI
import MetalKit
import SceneKit
import SceneKit.ModelIO
import SpriteKit
import CoreImage

struct FragmentUniforms {
    var cameraPosition: SIMD3<Float>
    var baseColor: SIMD3<Float>
    var roughness: Float
    var iridescenceFactor: Float
    var iridescenceIor: Float
    var iridescenceThicknessMin: Float
    var iridescenceThicknessMax: Float
}

class NormalMapFilter: CIFilter {
    var inputImage: CIImage?
    
    private static var kernel: CIKernel = {
        let url = Bundle.main.url(forResource: "NormalMap", withExtension: "ci.metallib")!
        let data = try! Data(contentsOf: url)
        return try! CIKernel(functionName: "normalMap", fromMetalLibraryData: data)
    }()
    
    override var outputImage: CIImage? {
        guard let input = inputImage else { return nil }
        return NormalMapFilter.kernel.apply(extent: input.extent,
                                            roiCallback: { (index, rect) in
                                                return rect
                                            },
                                            arguments: [input])
    }
}

struct SoundScreen: View {
    let sound: APIAppleSoundData
    
    @State private var scene: SCNScene?
    @State private var ellipsoidNode: SCNNode?
    @State private var isReversing = true
    
    @State private var iridescenceFactor: Float = 1.0
    @State private var iridescenceIor: Float = 1.35
    @State private var iridescenceThicknessMin: Float = 100.0
    @State private var iridescenceThicknessMax: Float = 400.0
    
    var body: some View {
        ZStack {
            if let scene = scene {
                SceneView(
                    scene: scene,
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
                .ignoresSafeArea()
            } else {
                ProgressView()
                    .ignoresSafeArea()
            }
            
            VStack {
                Spacer()

                Button {
                    self.scene = createScene()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
        .onAppear(perform: setupScene)
    }
    
    private func setupScene() {
        self.scene = createScene()
    }
    
    private func updateMaterial() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<FragmentUniforms>.stride, options: [])!
        var uniforms = FragmentUniforms(
            cameraPosition: SIMD3<Float>(0, 0, 0),
            baseColor: SIMD3<Float>(0.0, 0.0, 0.0),
            roughness: 0.1,
            iridescenceFactor: iridescenceFactor,
            iridescenceIor: iridescenceIor,
            iridescenceThicknessMin: iridescenceThicknessMin,
            iridescenceThicknessMax: iridescenceThicknessMax
        )
        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<FragmentUniforms>.stride)
        
        ellipsoidNode?.geometry?.firstMaterial?.setValue(uniformBuffer, forKey: "uniforms")
    }
}

// MARK: - Scene Setup
extension SoundScreen {
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black

        let discDiameter: CGFloat = 4
        let discThickness: CGFloat = 0.25

        let allocator = MTKMeshBufferAllocator(device: MTLCreateSystemDefaultDevice()!)
        let disc = MDLMesh.newEllipsoid(
            withRadii: vector_float3(Float(discDiameter / 2), Float(discDiameter / 2), Float(discThickness)),
            radialSegments: 64,
            verticalSegments: 64,
            geometryType: .triangles,
            inwardNormals: false,
            hemisphere: false,
            allocator: allocator
        )
        disc.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                             tangentAttributeNamed: MDLVertexAttributeTangent,
                             bitangentAttributeNamed: MDLVertexAttributeBitangent)
        
        print(disc.vertexDescriptor)

        let discGeometry = SCNGeometry(mdlMesh: disc)
        
        guard let ciCirclesImage = createCICirclesImage()
        else {
            fatalError("Failed to create normal map CIImage")
        }

        let material = createIridescentMaterial(normalMapCGImage: ciCirclesImage)
        discGeometry.materials = [material]

        let ellipsoidNode = SCNNode(geometry: discGeometry)
        self.ellipsoidNode = ellipsoidNode
        
        let ellipsoidParentNode = SCNNode()
        ellipsoidParentNode.addChildNode(ellipsoidNode)

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

    private func createCICirclesImage() -> CGImage? {
        guard let radialFilter = CIFilter(name: "CIGaussianGradient", parameters: [
            kCIInputCenterKey: CIVector(x: 50, y: 50),
            kCIInputRadiusKey: 45,
            "inputColor0": CIColor(red: 1, green: 1, blue: 1),
            "inputColor1": CIColor(red: 0, green: 0, blue: 0)
        ]) else {
            print("Failed to create radial filter")
            return nil
        }
        
        guard let initialImage = radialFilter.outputImage?
            .cropped(to: CGRect(x: 0, y: 0, width: 100, height: 100))
            .applyingFilter("CIAffineTile", parameters: [:])
            .cropped(to: CGRect(x: 0, y: 0, width: 1000, height: 500)) else {
            print("Failed to create initial CIImage")
            return nil
        }
        
        // Apply custom NormalMapFilter
        let normalMapFilter = NormalMapFilter()
        normalMapFilter.inputImage = initialImage
        guard let normalMapOutput = normalMapFilter.outputImage else {
            print("Failed to apply NormalMapFilter")
            return nil
        }
        
        guard let finalImage = CIFilter(name: "CIColorControls", parameters: [
            kCIInputImageKey: normalMapOutput,
            "inputContrast": 2.5
        ])?.outputImage else {
            print("Failed to apply contrast filter")
            return nil
        }
        
        let context = CIContext()
        guard let cgNormalMap = context.createCGImage(finalImage, from: finalImage.extent) else {
            print("Failed to create CGImage from CIImage")
            return nil
        }
        
        // Save the image to the file system
        let uiImage = UIImage(cgImage: cgNormalMap)
        if let data = uiImage.pngData() {
            let fileManager = FileManager.default
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("filteredImage.png")
                do {
                    try data.write(to: fileURL)
                    print("Image saved successfully to \(fileURL.path)")
                } catch {
                    print("Failed to save image: \(error)")
                }
            }
        } else {
            print("Failed to convert UIImage to PNG data")
        }
        
        return cgNormalMap
    }

    private func createIridescentMaterial(normalMapCGImage: CGImage) -> SCNMaterial {
        let material = SCNMaterial()
        
        let textureLoader = MTKTextureLoader(device: MTLCreateSystemDefaultDevice()!)
        let options: [MTKTextureLoader.Option: Any] = [.SRGB: false]
        let normalMapTexture = try! textureLoader.newTexture(cgImage: normalMapCGImage, options: options)

        // Other material properties
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            fatalError("Failed to create Metal device, default library, or shader functions")
        }

        let program = SCNProgram()
        program.vertexFunctionName = "vertexShader"
        program.fragmentFunctionName = "fragmentShader"
        material.program = program

        let uniformBuffer = device.makeBuffer(length: MemoryLayout<FragmentUniforms>.stride, options: [])!
        var uniforms = FragmentUniforms(
            cameraPosition: SIMD3<Float>(0, 0, 0),
            baseColor: SIMD3<Float>(1.0, 1.0, 1.0),
            roughness: 0.1,
            iridescenceFactor: iridescenceFactor,
            iridescenceIor: iridescenceIor,
            iridescenceThicknessMin: iridescenceThicknessMin,
            iridescenceThicknessMax: iridescenceThicknessMax
        )
        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<FragmentUniforms>.stride)
        
        material.setValue(uniformBuffer, forKey: "uniforms")
        material.setValue(normalMapTexture, forKey: "normalMap")
        
        return material
    }
    
    //    func createTextImage(text: String, size: CGSize, attributes: [NSAttributedString.Key: Any]) -> UIImage {
    //        let image = UIGraphicsImageRenderer(size: size).image { context in
    //            // Set black background
    //            UIColor.black.setFill()
    //            context.fill(CGRect(origin: .zero, size: size))
    //
    //            // Draw the white text on the black background
    //            let whiteTextAttributes: [NSAttributedString.Key: Any] = [
    //                .font: attributes[.font] ?? UIFont.systemFont(ofSize: 15),
    //                .foregroundColor: UIColor.white
    //            ]
    //            text.draw(in: CGRect(origin: .zero, size: size), withAttributes: whiteTextAttributes)
    //        }
    //
    //        let grayscaleImage = image.convertToGrayscale()
    //
    //        // Save the grayscale image to the file system for debugging
    //        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    //            let fileURL = documentsDirectory.appendingPathComponent("grayscaleTextImage.png")
    //            if let data = grayscaleImage.pngData() {
    //                try? data.write(to: fileURL)
    //                print("Grayscale text image saved to \(fileURL.path)")
    //            }
    //        }
    //
    //        return grayscaleImage
    //    }

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


extension UIImage {
    func convertToGrayscale() -> UIImage {
        let ciImage = CIImage(image: self)
        let grayscale = ciImage?.applyingFilter("CIColorControls", parameters: ["inputSaturation": 0.0])
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(grayscale!, from: grayscale!.extent)
        return UIImage(cgImage: cgImage!)
    }
}

//
//VStack {
//    HStack {
//        VStack(alignment: .leading) {
//            Text("Iridescence Factor")
//            HStack {
//                Text(String(format: "%.2f", iridescenceFactor))
//                Slider(value: $iridescenceFactor, in: 0.0...1.0)
//                    .onChange(of: iridescenceFactor) { _ in updateMaterial() }
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.7))
//        .cornerRadius(10)
//        
//        VStack(alignment: .leading) {
//            Text("Iridescence IOR")
//            HStack {
//                Text(String(format: "%.2f", iridescenceIor))
//                Slider(value: $iridescenceIor, in: 1.0...2.5)
//                    .onChange(of: iridescenceIor) { _ in updateMaterial() }
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.7))
//        .cornerRadius(10)
//    }
//    
//    HStack {
//        VStack(alignment: .leading) {
//            Text("Thickness Min")
//            HStack {
//                Text(String(format: "%.1f", iridescenceThicknessMin))
//                Slider(value: $iridescenceThicknessMin, in: 0.0...1000.0)
//                    .onChange(of: iridescenceThicknessMin) { _ in updateMaterial() }
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.7))
//        .cornerRadius(10)
//        
//        VStack(alignment: .leading) {
//            Text("Thickness Max")
//            HStack {
//                Text(String(format: "%.1f", iridescenceThicknessMax))
//                Slider(value: $iridescenceThicknessMax, in: 0.0...1000.0)
//                    .onChange(of: iridescenceThicknessMax) { _ in updateMaterial() }
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.7))
//        .cornerRadius(10)
//    }
//}
//.background(Color.clear)
