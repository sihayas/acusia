import Accelerate
import UIKit

func extractDominantColors(from imageURL: URL, k: Int = 3) -> [(red: Float, green: Float, blue: Float)]? {
    guard let image = UIImage(contentsOfFile: imageURL.path),
          let cgImage = image.cgImage else {
        return nil
    }
    
    let dimension = 100 // Scale to 100x100 pixels for processing
    var redStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: dimension * dimension)
    var greenStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: dimension * dimension)
    var blueStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: dimension * dimension)
    
    defer {
        redStorage.deallocate()
        greenStorage.deallocate()
        blueStorage.deallocate()
    }
    
    // vImage Pixel Buffers
    let redBuffer = vImage.PixelBuffer<vImage.PlanarF>(
        data: redStorage.baseAddress!,
        width: dimension,
        height: dimension,
        byteCountPerRow: dimension * MemoryLayout<Float>.stride
    )
    
    let greenBuffer = vImage.PixelBuffer<vImage.PlanarF>(
        data: greenStorage.baseAddress!,
        width: dimension,
        height: dimension,
        byteCountPerRow: dimension * MemoryLayout<Float>.stride
    )
    
    let blueBuffer = vImage.PixelBuffer<vImage.PlanarF>(
        data: blueStorage.baseAddress!,
        width: dimension,
        height: dimension,
        byteCountPerRow: dimension * MemoryLayout<Float>.stride
    )
    
    // Convert the image into RGB components and store them in the buffers.
    // You will need to add your own image processing logic here.
    
    // Initialize centroids
    var centroids: [(red: Float, green: Float, blue: Float)] = []
    for _ in 0..<k {
        let randomIndex = Int.random(in: 0 ..< dimension * dimension)
        centroids.append((red: redStorage[randomIndex], green: greenStorage[randomIndex], blue: blueStorage[randomIndex]))
    }
    
    // k-means iteration (simplified example)
    var distances = UnsafeMutableBufferPointer<Float>.allocate(capacity: dimension * dimension * k)
    defer {
        distances.deallocate()
    }
    
    // Iterate until centroids converge (simplified logic)
    for _ in 0..<10 { // Run a fixed number of iterations
        for (index, centroid) in centroids.enumerated() {
            distanceSquared(x0: greenStorage.baseAddress!, x1: centroid.green,
                            y0: blueStorage.baseAddress!, y1: centroid.blue,
                            z0: redStorage.baseAddress!, z1: centroid.red,
                            n: greenStorage.count,
                            result: distances.baseAddress!.advanced(by: dimension * dimension * index))
        }
        
        // Update centroids (this is a simplified version)
        // Gather pixels closest to each centroid and update centroids
        for i in 0..<k {
            let indices = makeCentroidIndices(k: i, distances: distances, dimension: dimension, totalCount: dimension * dimension, numCentroids: k)
            let gatheredRed = vDSP.gather(redStorage, indices: indices)
            let gatheredGreen = vDSP.gather(greenStorage, indices: indices)
            let gatheredBlue = vDSP.gather(blueStorage, indices: indices)
            
            centroids[i].red = vDSP.mean(gatheredRed)
            centroids[i].green = vDSP.mean(gatheredGreen)
            centroids[i].blue = vDSP.mean(gatheredBlue)
        }
    }
    
    // Return the final centroids as dominant colors
    return centroids
}

// Helper function: Calculate the distance squared between pixels and centroids
func distanceSquared(x0: UnsafePointer<Float>, x1: Float,
                     y0: UnsafePointer<Float>, y1: Float,
                     z0: UnsafePointer<Float>, z1: Float,
                     n: Int, result: UnsafeMutablePointer<Float>) {
    for i in 0..<n {
        let dx = x0[i] - x1
        let dy = y0[i] - y1
        let dz = z0[i] - z1
        result[i] = dx * dx + dy * dy + dz * dz
    }
}

// Helper function: Find the nearest centroid for each pixel
func makeCentroidIndices(k: Int, distances: UnsafeMutableBufferPointer<Float>, dimension: Int, totalCount: Int, numCentroids: Int) -> [UInt] {
    var indices = [UInt]()
    let startIndex = dimension * dimension * k
    
    for i in 0..<totalCount {
        let minDist = distances[startIndex + i]
        var closestCentroid = k
        for j in 0..<numCentroids {
            if distances[dimension * dimension * j + i] < minDist {
                closestCentroid = j
            }
        }
        
        if closestCentroid == k {
            indices.append(UInt(i + 1))  // One-based index for vDSP.gather
        }
    }
    
    return indices
}
