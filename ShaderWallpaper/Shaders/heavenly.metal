//
//  heavenly.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//

#include <metal_stdlib>
#include "common.metal"
using namespace metal;

fragment float4 heavenlyShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float2 R = u.resolution;
    float T = u.time;

    float2 frag = uv * R;

    float4 fragColor = float4(0.0);

    float z = 0.0;
    float d = 0.0;

    // reduced 100 → 64
    for (int i = 0; i < 64; i++) {

        float3 dir = normalizeSafe(float3(frag * 2.0 - R, R.y));
        float3 p = z * dir;

        p.z -= T;

        d = 1.0;

        // inner loop reduced 9 → 6
        for (int j = 0; j < 6; j++) {
            p += cos(p.yzx * d + z * 0.2) / d;
            d /= 0.7;
        }

        d = 0.02 + 0.1 * abs(3.0 - length(p.xy));
        z += d;

        fragColor += (cos(z + T + float4(6.0, 1.0, 2.0, 3.0)) + 1.0) / d;

        if (z > 50.0) break;
    }

    fragColor = tanh(fragColor / 3000.0);

    return float4(fragColor.rgb, 1.0);
}
