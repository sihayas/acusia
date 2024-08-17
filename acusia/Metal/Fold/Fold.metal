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

float smoothStep(float edge0, float edge1, float x) {
    x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return x*x*x*(x*(x*6.0-15.0)+10.0);
}

[[ stitchable ]] float2 distortion(float2 position, float4 bounds, float centerX, float progressX, float progressY, float progressTranslationY) {

    float2 size = float2(bounds[2], bounds[3]);

    // Start with no curve when progressY = 1.0 (i.e., no distortion)
    float centerY = size.y * 0.5;
    centerX = size.x * 0.5;
    float distanceFromCenterY = position.y - centerY;

    // Curvature, inverted logic
    float curveFactor = mapRange(progressY, 1.0, 0.0, 0.0, -0.3);  // Ensure no distortion at 1.0, full distortion at 0.0

    float curvedX = position.x + curveFactor * pow(abs(distanceFromCenterY) / size.y, 2.0) * (position.x - centerX);
    
    float stretchFactor = mapRange(progressY, 1.0, 0.0, 1.0, 0.95);
    float stretchedY = centerY + (distanceFromCenterY * stretchFactor);

    return float2(curvedX, stretchedY);
}
