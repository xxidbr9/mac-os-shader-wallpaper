//
//  pilar.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//


#include <metal_stdlib>
#include "common.metal"
using namespace metal;

// TODO: wrong color
fragment float4 pilarShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {
    float2 R = u.resolution;
    float T = u.time;

    // fragCoord
    float2 C = in.texCoord * R;

    // p
    float2 p = (2.0 * C - R) / R.y / 0.3 + T * float2(2.0 / PI, 1.0);

    // w
    float2 w = fmod(p, 2.0) - 1.0;

    // sqrt(1 - w*w)
    float2 s = sqrt(max(float2(0.0), 1.0 - w * w));

    // core expression
    float v = p.y
        - s.x * cos(ceil(p.x * 0.5) * PI);

    float3 col = sin(v + float3(1.0, 1.0, 2.0));

    return float4(col, 1.0);
}
