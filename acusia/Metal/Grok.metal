//
//  Grok.metal
//  acusia
//
//  Created by decoherence on 10/31/24.
//

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] float2 complexWave(float2 position, float time, float2 size, float speed, float strength, float frequency) {
    float2 normalizedPosition = position / size;
    float moveAmount = time * speed;

    position.x += sin((normalizedPosition.x + moveAmount) * frequency) * strength;
    position.y += cos((normalizedPosition.y + moveAmount) * frequency) * strength;

    return position;
}
