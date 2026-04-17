//
//  marbel.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//

#include <metal_stdlib>
#include "common.metal"
using namespace metal;

void F(thread float2 &I,
            thread float4 &fragColor,
            float a,
            float time)
{
    for (float n = -0.3; n < 8.0; n += 1.0) {
        float2 v = sin(I.yx * n + time * n) / n;
        I += 1.2 * max(v, float2(0.0));
    }

    fragColor += 1.0 + sin(I.y + float4(a, 0.0, 1.0, 0.0));
}

fragment float4 marbleShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float2 R = u.resolution;
    float T = u.time;

    // coord transform (match GLSL)
    float2 I = 4.0 * (2.0 * uv * R - R) / R.y;

    float4 fragColor = float4(0.0);

    F(I, fragColor, 0.0, T);
    F(I, fragColor, 0.0, T);
    F(I, fragColor, 2.0, T);

    fragColor /= 6.0;

    return float4(fragColor.rgb, 1.0);
}
