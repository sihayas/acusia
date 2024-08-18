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

float foldMapRange(float value, float inMin, float inMax, float outMin, float outMax) {
    return ((value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin);
}


[[ stitchable ]] float2 fold(float2 position, float4 bounds, float centerX, float progressX, float progressY, float progressTranslationY) {

    // Get the width and height of the view
    float2 size = float2(bounds[2], bounds[3]);

    // Find the vertical and horizontal centers of the view (where the fold happens)
    float centerY = size.y * 0.5;
    centerX = size.x * 0.5;
    
    // Calculate distance from the vertical center (used to determine fold amount)
    float distanceFromCenterY = position.y - centerY;

    // Make the curve factor more sensitive (increase the effect for small progressY values)
    float sensitivity = 0.15; // Increase this value for more sensitivity
    float curveFactor = foldMapRange(progressY, 1.0, 0.0, 0.0, -0.3 * sensitivity);

    // Apply curvature to the X position to simulate bending
    float curvedX = position.x + curveFactor * pow(abs(distanceFromCenterY) / size.y, 2.0) * (position.x - centerX);
    
    // Make the stretch factor more sensitive (increase the compression for small progressY values)
    float stretchFactor = foldMapRange(progressY, 1.0, 0.0, 1.0, 0.95 - (0.05 * (sensitivity - 1.0)));

    // Apply the stretch to the Y position to simulate the vertical squeeze
    float stretchedY = centerY + (distanceFromCenterY * stretchFactor);

    // Return the final adjusted position with the X curvature and Y stretch applied
    return float2(curvedX, stretchedY);
}
