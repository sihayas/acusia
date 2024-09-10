#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[ stitchable ]] half4 iridescentEffect(float2 position, SwiftUI::Layer layer, float time, texture2d<float> perlinTexture, texture2d<float> voronoiTexture) {
    half4 baseColor = layer.sample(position); // Sample pixel from the layer

    // Define a sampler with default settings
    sampler textureSampler(filter::linear, address::repeat);

    // Sample Perlin and Voronoi noise textures using the sampler
    half4 perlin = half4(perlinTexture.sample(textureSampler, position));
    half4 voronoi = half4(voronoiTexture.sample(textureSampler, position));


    // Simulate lighting using position and noise
    float NdotL = sin(position.x * 0.05 + time) * cos(position.y * 0.05 + time);
    
    half4 color = mix(baseColor, perlin + voronoi, half(NdotL));

    return half4(color);
}
