//
//  ArtifactCard.swift
//  acusia
//
//  Created by decoherence on 7/16/24.
//
import SwiftUI
import SceneKit

struct ArtifactSceneView: View {
    let entry: APIEntry
    
    var appleData: APIAppleSoundData {
        entry.sound.appleData ?? APIAppleSoundData(id: "", type: "", name: "", artistName: "", albumName: "", releaseDate: "", artworkUrl: "", artworkBgColor: "", identifier: "", trackCount: nil)
    }
    
    @State private var cardImage: UIImage?
    @State private var authorImage: UIImage?
    @State private var scene: SCNScene?
    @State private var cardNode: SCNNode?
    @State private var isReversing = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let scene = scene {
                SceneView(scene: scene)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: loadImages)
    }
    
    private func loadImages() {
        loadImage(from: appleData.artworkUrl) { self.cardImage = $0; self.scene = createScene() }
        loadImage(from: entry.author.image) { self.authorImage = $0 }
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        let modifiedUrlString = urlString
            .replacingOccurrences(of: "{w}", with: "1000")
            .replacingOccurrences(of: "{h}", with: "1000")
        
        guard let url = URL(string: modifiedUrlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                completion(data.flatMap(UIImage.init))
            }
        }.resume()
    }
}

// MARK: - SceneView
extension ArtifactSceneView {
    private func createScene() -> SCNScene {
        // Card shape and radius
        let scene = SCNScene()
        scene.background.contents = UIColor.black

        let cardWidth: CGFloat = 2
        let cardHeight: CGFloat = 3
        let cardThickness: CGFloat = 0.05
        
        let cornerRadius: CGFloat = 0.25
        let path = UIBezierPath(roundedRect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight), cornerRadius: cornerRadius)
        path.flatness = 0
        let shape = SCNShape(path: path, extrusionDepth: cardThickness)
        
        // MARK: Card Materials
        let gunmetalColor = UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1.0)

        // TODO: Change material to be like a CD, iridescent.
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = gunmetalColor
        baseMaterial.specular.contents = UIColor.white
        baseMaterial.shininess = 1.0
        baseMaterial.metalness.contents = 1.0
        baseMaterial.roughness.contents = 0.0

        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = gunmetalColor
        sideMaterial.specular.contents = UIColor.white
        sideMaterial.shininess = 1.0
        sideMaterial.metalness.contents = 1.0
        sideMaterial.roughness.contents = 0.0

        shape.materials = [baseMaterial, baseMaterial, sideMaterial, sideMaterial, sideMaterial, sideMaterial]
        
        cardNode = SCNNode(geometry: shape)
        
        // MARK: Front Face
        if let cardImage = cardImage {
            let imageSize = min(cardWidth, cardHeight)
            let imagePath = UIBezierPath(roundedRect: CGRect(x: -imageSize/2, y: -imageSize/2, width: imageSize, height: imageSize),
                                         byRoundingCorners: [.bottomLeft, .bottomRight],
                                         cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            imagePath.flatness = 0
            
            let imageShape = SCNShape(path: imagePath, extrusionDepth: 0.001)
            let imageMaterial = SCNMaterial()
            imageMaterial.diffuse.contents = cardImage
            imageMaterial.specular.contents = UIColor.white
            imageMaterial.shininess = 1.0
            imageMaterial.metalness.contents = 1.0
            imageMaterial.roughness.contents = 0.0
            imageMaterial.isDoubleSided = true
            imageShape.materials = [imageMaterial]
            
            let imageNode = SCNNode(geometry: imageShape)
            imageNode.position = SCNVector3(0, cardHeight/2 - imageSize/2, cardThickness/2 + 0.001)
            cardNode?.addChildNode(imageNode)
            
            let circleSize: CGFloat = 0.5

            // Create circle node
            let circlePlane = SCNPlane(width: circleSize, height: circleSize)
            let circleMaterial = SCNMaterial()
            circleMaterial.diffuse.contents = UIImage(named: "circle")
            circleMaterial.isDoubleSided = true
            circlePlane.materials = [circleMaterial]
            let circleNode = SCNNode(geometry: circlePlane)

            circleNode.position = SCNVector3(0, cardHeight/2 - imageSize - circleSize/2 - 0.2, cardThickness/2 + 0.002)
            cardNode?.addChildNode(circleNode)
            
        }
        
        // MARK: Backface
        
        // sound titles
        let pointsToSceneKitUnits: CGFloat = 0.01 // 100 points = 1 SceneKit
        let alignToTop: CGFloat = cardHeight/2 - 0.2
        let alignToBottom: CGFloat = -cardHeight/2 + 0.2
        let padding = 24 * pointsToSceneKitUnits

        func createEtchedText(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight, maxWidth: CGFloat, maxHeight: CGFloat) -> SCNNode {
            // create a container for our etched text
            let containerNode = SCNNode()
            
            // create the text geometry
            let textGeometry = SCNText(string: text, extrusionDepth: 0.001)
            textGeometry.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
            textGeometry.flatness = 0.1
            textGeometry.chamferRadius = 0.0001
            
            // calculate the bounding box of the text
            let (minVec, maxVec) = textGeometry.boundingBox
            let textWidth = CGFloat(maxVec.x - minVec.x)
            let textHeight = CGFloat(maxVec.y - minVec.y)
            
            // set a consistent scale factor for the SceneKit points to unit conversion
            let scale = Float(0.01)  // Adjust this value as needed for your scene scale
            
            // create a node for the text and set its properties
            let textNode = SCNNode(geometry: textGeometry)
            textNode.scale = SCNVector3(scale, scale, scale)
            textNode.position = SCNVector3(
                Float(-textWidth) * scale / 2,
                Float(-textHeight) * scale / 2,
                0.001 // slightly raised above the card surface
            )
            
            // create materials for the etched effect
            let etchedMaterial = SCNMaterial()
            etchedMaterial.diffuse.contents = UIColor.darkGray
            etchedMaterial.specular.contents = UIColor.white
            etchedMaterial.shininess = 0.5
            etchedMaterial.roughness.contents = 0.8
            
            let shadowMaterial = SCNMaterial()
            shadowMaterial.diffuse.contents = UIColor.black.withAlphaComponent(0.3)
            
            textGeometry.materials = [etchedMaterial, shadowMaterial]
            
            // add the text node to the container
            containerNode.addChildNode(textNode)
            
            return containerNode
        }
        
        // create etched text nodes
        let artistTextNode = createEtchedText(text: appleData.artistName, fontSize: 13, fontWeight: .regular, maxWidth: cardWidth * 0.8, maxHeight: cardHeight * 0.1)
        let albumTextNode = createEtchedText(text: appleData.name, fontSize: 13, fontWeight: .semibold, maxWidth: cardWidth * 0.8, maxHeight: cardHeight * 0.1)
        
        artistTextNode.position = SCNVector3(
            0,
            alignToTop - padding,
            -cardThickness/2 - 0.001
        )
        albumTextNode.position = SCNVector3(
            0,
            alignToTop - padding * 2 - 0.1,
            -cardThickness/2 - 0.001
        )
        
        // rotate the text nodes to face the back of the card
        artistTextNode.eulerAngles.y = .pi
        albumTextNode.eulerAngles.y = .pi
        
        // add the text nodes to the card
        cardNode?.addChildNode(artistTextNode)
        cardNode?.addChildNode(albumTextNode)

        let ratingImage = UIImage(named: "circle")
        let ratingPlane = SCNPlane(width: 0.5, height: 0.5)
        ratingPlane.firstMaterial?.diffuse.contents = ratingImage
        ratingPlane.firstMaterial?.isDoubleSided = true
        let ratingNode = SCNNode(geometry: ratingPlane)
        ratingNode.position = SCNVector3(
            0,
            0,
            -cardThickness/2 - 0.001
        )
        ratingNode.eulerAngles.y = .pi
        cardNode!.addChildNode(ratingNode)
        
        let usernameNode = createEtchedText(text: "@\(entry.author.username)", fontSize: 13, fontWeight: .regular, maxWidth: cardWidth * 0.8, maxHeight: cardHeight * 0.1)
        usernameNode.position = SCNVector3(
            0,
            alignToBottom + padding,
            -cardThickness/2 - 0.001
        )
        usernameNode.eulerAngles.y = .pi // flip text
        cardNode!.addChildNode(usernameNode)

        // MARK: Setup Card Parent Node
        let cardParentNode = SCNNode()
        cardParentNode.addChildNode(cardNode!)
        
        // MARK: Lights
        let mainLight = SCNNode()
        mainLight.light = SCNLight()
        mainLight.light!.type = .directional
        mainLight.light!.color = UIColor(white: 0.9, alpha: 1.0)
        mainLight.light!.intensity = 1000
        mainLight.position = SCNVector3(x: 5, y: 5, z: 10)
        mainLight.constraints = [SCNLookAtConstraint(target: cardParentNode)]
        scene.rootNode.addChildNode(mainLight)
        
        let secondaryLight = SCNNode()
        secondaryLight.light = SCNLight()
        secondaryLight.light!.type = .directional
        secondaryLight.light!.color = UIColor(white: 0.8, alpha: 1.0)
        secondaryLight.light!.intensity = 250
        secondaryLight.position = SCNVector3(x: -3, y: -3, z: 5)
        secondaryLight.constraints = [SCNLookAtConstraint(target: cardParentNode)]
        scene.rootNode.addChildNode(secondaryLight)
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = UIColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        func addRimLight(position: SCNVector3) {
            let rimLight = SCNNode()
            rimLight.light = SCNLight()
            rimLight.light!.type = .spot
            rimLight.light!.color = UIColor(white: 0.95, alpha: 1.0)
            rimLight.light!.intensity = 80
            rimLight.light!.spotInnerAngle = 0
            rimLight.light!.spotOuterAngle = 90
            rimLight.light!.attenuationStartDistance = 5
            rimLight.light!.attenuationEndDistance = 20
            rimLight.position = position
            rimLight.constraints = [SCNLookAtConstraint(target: cardParentNode)]
            scene.rootNode.addChildNode(rimLight)
        }
        
        addRimLight(position: SCNVector3(x: 10, y: 0, z: 0))   // Right
        addRimLight(position: SCNVector3(x: -10, y: 0, z: 0))  // Left
        addRimLight(position: SCNVector3(x: 0, y: 10, z: 0))   // Top
        addRimLight(position: SCNVector3(x: 0, y: -10, z: 0))  // Bottom
        addRimLight(position: SCNVector3(x: 7, y: 7, z: 7))    // Top-Right
        addRimLight(position: SCNVector3(x: -7, y: 7, z: 7))   // Top-Left
        addRimLight(position: SCNVector3(x: 7, y: -7, z: 7))   // Bottom-Right
        addRimLight(position: SCNVector3(x: -7, y: -7, z: 7))  // Bottom-Left
        
        // MARK: Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
        cameraNode.camera!.fieldOfView = 30
        cameraNode.camera!.zNear = 1
        cameraNode.camera!.zFar = 100
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cardParentNode)
        
        // MARK: Action!
        
        // initial setup: small scale, positioned to the right, tilted
        cardParentNode.scale = SCNVector3(0.0, 0.0, 0.0)
        cardParentNode.position = SCNVector3(-2.5, 0, 0)  // Start from the bottom left
        cardParentNode.eulerAngles.y = Float.pi + Float.pi * 0.2
        
        playAnimationSequence(cardNode: cardParentNode, isReversing: isReversing)
        
        return scene
    }
}

// MARK: - Animation Helpers
extension ArtifactSceneView {
    func playAnimationSequence(cardNode: SCNNode, isReversing: Bool) {
        playForwardAnimation(cardNode: cardNode)
    }
    
    private func playForwardAnimation(cardNode: SCNNode) {
        let animateCombined = SCNAction.customAction(duration: 1.0) { node, elapsedTime in
            let progress = Float(elapsedTime) / 1.0
            let easeProgress = self.translationEasing(progress)

            node.scale = SCNVector3(easeProgress, easeProgress, easeProgress)
            node.position.x = -2.5 * (1 - easeProgress)
            node.position.y = 0 * (1 - easeProgress)

            let rotationProgress = Float(elapsedTime) / 1.0
            let easedRotationProgress = self.rotationEasing(min(rotationProgress, 1))
            let totalRotation = Float.pi + Float.pi * 0.2
            let rotation = Float.pi + Float.pi * 0.2 - easedRotationProgress * totalRotation

            node.eulerAngles.y = rotation
        }

        let slowRotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi / -10, z: 0, duration: 0.25))

        let sequence = SCNAction.sequence([animateCombined, slowRotate])
        cardNode.removeAllActions()
        cardNode.runAction(sequence)
    }


    private func translationEasing(_ t: Float) -> Float {
        return 1 - pow(1 - t, 5)
    }
    
    private func rotationEasing(_ t: Float) -> Float {
        return 1.0 - pow(1.0 - t, 3)
    }
}
