//
//  blackHoles.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//

#include <metal_stdlib>
#include "common.metal"
using namespace metal;


fragment float4 blackHoleShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float2 R = u.resolution;
    float T = u.time;

    float2 frag = uv * R;

    float4 fragColor = float4(0.0);

    // p
    float2 p = float2(
        -(frag.x * 2.0 - R.x),
         (frag.y * 2.0 - R.y)
    ) / R.y / 0.7;

    float2 d = float2(-1.0, 1.0);

    // matrix construction (mat2(1,1,d/(...)))
    float denom = 0.1 + 5.0 / dot(5.0 * p - d, 5.0 * p - d);
    float2 d2 = d / denom;

    float2x2 m = float2x2(
        float2(1.0, 1.0),
        d2
    );

    float2 c = p * m;

    float2 v = c;

    // rotation matrix from vec4 trick
    float lenv = length(v);
    float base = log(lenv) + T * 0.2;

    float c1 = cos(base + 0.0);
    float c2 = cos(base + 33.0);
    float c3 = cos(base + 11.0);
    float c4 = cos(base + 0.0);

    float2x2 rotm = float2x2(
        float2(c1, c2),
        float2(c3, c4)
    );

    v = (rotm * v) * 5.0;

    // loop (explicit)
    for (float i = 1.0; i < 9.0; i += 1.0) {

        float4 add = sin(float4(v.x, v.y, v.y, v.x)) + 1.0;
        fragColor += add;

        float2 term = sin(v.yx * i + T) / i;
        v += 0.7 * term + 0.5;
    }

    // final expression (expanded)
    float4 exp1 = exp(c.x * float4(0.6, -0.4, -1.0, 0.0));

    float lenTerm = length(sin(v / 0.3) * 0.2 + c * float2(1.0, 2.0)) - 1.0;
    float shape = 0.1 + 0.1 * pow(lenTerm, 2.0);

    float falloff = (1.0 + 7.0 * exp(0.3 * c.y - dot(c, c)));
    float ring = 0.03 + abs(length(p) - 0.7);

    fragColor = 1.0 - exp(
        -exp1 / fragColor / shape / falloff / ring * 0.2
    );

    return float4(fragColor.rgb, 1.0);
}
