#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[stitchable]] half4 iridescent(
    float2 pos, half4 color, float t, float randomOffset) {
    
    // Parameters for the iridescence effect
    float thickness = mix(100.0, 400.0, sin(t * 0.5)); // Vary thickness over time
    float iridescenceIor = 1.7;  // Index of refraction for the thin-film layer
    float outsideIor = 1.0;      // IOR of air
    
    // Calculate angles
    float angle = atan2(pos.y, pos.x);
    
    // Slow down the animation by multiplying t by 0.2
    float phaseShift = (2.0 * M_PI_F * thickness / 550.0) *
                       (iridescenceIor - outsideIor) * cos(angle + t * 0.2 + randomOffset);

    // Adjust the frequency of the cosine modulation for the slower animation
    float iridescenceMask = 0.5 + 0.5 * cos(phaseShift * 2.0); // Reduced frequency

    // Base dark gray color (unchanged)
    half4 baseColor = half4(0.11, 0.11, 0.12, color.a);

    // Subtle iridescent effect overlay
    half4 iridescenceColor = half4(
        0.1 * sin(phaseShift),
        0.1 * sin(phaseShift + 2.0),
        0.1 * sin(phaseShift + 4.0),
        0.0
    );

    // Blend the iridescence with the base color, creating smoother transitions
    half3 finalColor = mix(baseColor.rgb, baseColor.rgb + iridescenceColor.rgb, iridescenceMask) * color.a;

    // Return the final color with the alpha channel intact
    return half4(finalColor, color.a);
}
