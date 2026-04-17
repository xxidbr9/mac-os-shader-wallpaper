//
//  tile.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//

#include <metal_stdlib>
#include "common.metal"
using namespace metal;

fragment float4 tileShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {
    float2 R = u.resolution;
    float T = u.time;

    // equivalent of C.xy (fragCoord)
    float2 C = in.texCoord * R;

    // p = (2*C.xy - R) / R.y * 5
    float2 p = (2.0 * C - R) / R.y * 5.0;

    // core expression
    float v = length(tan(p) + p);

    float3 col = cos(v - T + float3(1.0, 0.7, 1.0));

    return float4(col, 1.0);
}
