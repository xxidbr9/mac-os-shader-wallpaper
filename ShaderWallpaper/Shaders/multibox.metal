//
//  multibox.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//

#include <metal_stdlib>
#include "common.metal"
using namespace metal;


// =====================
// Fragment shader
// =====================
fragment float4 multiBoxShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float2 R = u.resolution;
    float T = u.time;

    // convert to screen space
    float2 frag = uv * R;

    float3 dir = normalizeSafe(float3(frag - 0.5 * R, R.y));

    float z = 0.0;
    float d = 0.0;

    float4 O = float4(0.0);

    // reduced from 100 → 64 for performance
    for (int i = 0; i < 64; i++) {

        float3 p = z * 0.5 * dir;

        // expanded weird rotation logic
        float4 offsets = float4(0.0, 11.0, 33.0, 0.0);
        float angle = p.z * 0.1 - offsets.y; // simplified approximation

        float2 r = rot(p.xy, cos(angle));
        p = float3(r, p.z + T);

        float3 q = abs(fract3(p) - 0.5) - 0.5;

        float boxDist =
            length(max(q, float3(0.4))) +
            max(q.x, max(q.y, q.z)) - 0.4;

        float wave = abs(sin(length(p.xy) + p.z - T * 0.5) * 0.4) * 0.01;

        d = abs(boxDist) + wave + 0.0001;

        z += d;

        O += 4.0 / d;

        if (z > 50.0) break; // early exit
    }

    O *= float4(1.0, 1.0, 3.0, 0.0) / 400000.0;

    return float4(O.rgb, 1.0);
}
