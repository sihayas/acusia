//
//  Shader.metal
//  StickerWall
//
//  Created by Daniel Korpai on 12/03/2024.
//  Contact and more details at https://danielkorpai.com
//
//  Original shader effect created by Alex Widua on 01/04/24.
//  Original distortion effect created by Janum Trivedi on 12/30/23.
//
#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>

using namespace metal;

float mapRange(float value, float inMin, float inMax, float outMin, float outMax) {
    return ((value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin);
}

// Smoother Step function by Inigo Quilez, 2022 (MIT)
// https://www.shadertoy.com/view/st2BRd
float smoothStep(float edge0, float edge1, float x) {
    x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return x*x*x*(x*(x*6.0-15.0)+10.0);
}

[[ stitchable ]] float2 distortion(float2 position, float4 bounds, float centerX, float progressX, float progressY, float progressTranslationY) {
    
    float2 size = float2(bounds[2], bounds[3]);
    
    // 1. Squeeze the layer on the x axis
    const float squeezeAmount = 1.22; // This equals with 66% scale at the moment
    float squeezeFactor = mapRange(progressX, 0.0, 1.0, 1.0, squeezeAmount);
    float mappedSqueezeCenter = size.x * 0.5;
    float distanceFromCenter = position.x - mappedSqueezeCenter;
    
    // 2. Apply the x-squeeze along the y-axis (aka. how much of the layer is squeezed at the same time)
    float mappedSqueezeProgress = mapRange(progressY, 0.0, 1.0, 1.0, -3.5);
    
    // smooth the squeeze using a smoothStep function
    // Ref: https://thebookofshaders.com/05/
    float s = smoothStep(mappedSqueezeProgress * size.y, size.y, position.y);
    float smoothedSqueeze = 1.0 + (squeezeFactor - 0.7) * s;
    float squeezedX = mappedSqueezeCenter + distanceFromCenter * smoothedSqueeze;

    // 3. Stretch the layer along the y axis
    //
    // Because we >squeeze< the layer horizontally, we want to <stretch> it vertically – this helps to sell the Genie effect and makes the whole thing feel good.

    const float stretchCenterY = 0.5;
    const float stretchAmount = 0.5; // This equals with 66% scale at the moment
    float stretchFactorY = mapRange(progressY, 0.0, 1.0, 0.0,  stretchAmount);
    float distanceFromCenterY = position.y - stretchCenterY * size.y;
    float stretchedY = stretchCenterY * size.y + distanceFromCenterY * (1.0 + stretchFactorY);

    float translatedY = stretchedY;
    
    return float2(squeezedX, translatedY);
}


// bounds[2] = width of the rectangle
// bounds[3] = height of the rectangle
// float[2] = vector containing the width and height of the rectangle
// normalization = mapping values to a scale of 0.0 - 1.0, so we can work with them
