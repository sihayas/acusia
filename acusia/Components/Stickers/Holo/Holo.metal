#include <metal_stdlib>
using namespace metal;


struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
    float3 worldNormal;
    float3 worldPosition;
};

struct VertexIn {
    float3 position [[attribute(0)]];
    float2 normal [[attribute(1)]];
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float3 lightDirection;
    float padding;
    float rotationAngleX;
    float rotationAngleY;
    float time;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]]) {
    float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);
    VertexOut out {
        .position = uniforms.viewProjectionMatrix * worldPosition,
        .texCoord = in.normal,
        .worldNormal = normalize((uniforms.modelMatrix * float4(in.position, 0.0)).xyz),
        .worldPosition = worldPosition.xyz
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(1)]],
                              texture2d<float> rampTexture [[texture(0)]],
                              texture2d<float> noiseTexture [[texture(1)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    // Sample the noise texture and convert it to a normal map
    float3 normalMap = noiseTexture.sample(textureSampler, in.texCoord).rgb * 2.0 - 1.0;
    
    // Normalize the normal map and combine it with the world normal
    float3 normal = normalize(in.worldNormal);
    
    // Adjust the 1.0 to control the bump strength
    float3 fullNormal = normalize(normal + normalMap * 0.5);
    
    // Calculate the dot product between the light direction and the full normal
    float NdotL = dot(uniforms.lightDirection, fullNormal);

    // Adjust the color change based on rotation angles
    float rotationEffect = sin(uniforms.rotationAngleX * 0.1) * cos(uniforms.rotationAngleY * 0.1);
    
    // Sample the ramp texture using the dot product result
    float2 rampUV = float2(NdotL * 0.5 + 0.5 + rotationEffect, 0.5);
    float3 rampColor = rampTexture.sample(textureSampler, rampUV).rgb;
    
    return float4(rampColor, 1.0);
}
