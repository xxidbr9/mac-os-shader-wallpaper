//
//  shiny.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//


#include <metal_stdlib>
#include "common.metal"
using namespace metal;

// =====================
// Helpers
// =====================

float Tval(float t) {
    return sin(t * 0.6) * 16.0 + t * 100.0;
}

float3 P(float z) {
    return float3(
        cos(z * 0.011) * 16.0 + cos(z * 0.012) * 24.0,
        cos(z * 0.01) * 4.0,
        z
    );
}


float2x2 rot(float a) {
    float c = cos(a);
    float s = sin(a);
    return float2x2(float2(c, -s), float2(s, c));
}

float boxen(float3 p) {
    p = abs(fract(p / 20.0) * 20.0 - 10.0) - 1.0;
    return min(p.x, min(p.y, p.z));
}

// =====================
// MAP
// =====================
float map(float3 p, thread float4& lights, float T) {

    float3 q = P(p.z);
    float g = q.y - p.y + 6.0;

    float m = boxen(p);

    float e = 0.001 + abs(length(p - float3(
        q.x + sin(T * 0.05),
        q.y + cos(T * 0.04),
        T + 10.0
    )) - 0.02);

    lights += float4(1.0, 3.0, 13.0, 0.0) / e;

    p.xy -= q.xy;

    float red = length(p.xy - sin(p.z / 12.0 + float2(0.0,1.3)) * 12.0) - 1.0;
    float blue = length(p.xy - sin(p.z / 16.0 + float2(0.0,0.7)) * 16.0) - 2.0;

    e = min(red, blue);

    lights += float4(10.0,2.0,1.0,0.0) / (0.1 + abs(red));
    lights += float4(1.0,2.0,10.0,0.0) / (0.1 + abs(blue) / 10.0);

    p = abs(p);

    float tex = abs(length(sin(p * cos(p.yzx / 30.0) * 4.0) / (p * 4.0)));
    float tun = min(32.0 - p.x - p.y, 24.0 - p.y);

    float d = max(min(m, g), tun) - tex;

    return min(e, d);
}

// =====================
// Fragment
// =====================
fragment float4 shinyShader(
    VertexOut in [[stage_in]],
    constant Uniforms& u [[buffer(0)]]
) {

    float2 uv = in.texCoord;
    float2 R = u.resolution;
    float t = u.time;

    float2 frag = uv * R;

    float2 u2 = (frag - R * 0.5) / R.y;
    u2.y -= 0.2;

    float T = Tval(t);

    float4 fragColor = float4(0.0);

    float3 p = P(T);
    float3 ro = p;

    float3 Z = normalizeSafe(P(T + 2.0) - p);
    float3 X = normalizeSafe(float3(Z.z, 0.0, -Z.x));
    float3 Y = cross(X, Z);

    float3 D = normalizeSafe(float3(u2, 1.0));
    D = float3(
        dot(D, -X),
        dot(D, Y),
        dot(D, Z)
    );

    float d = 0.0;
    float s = 0.0;
    float4 lights = float4(0.0);

    // reduced steps (100 → 48)
    for (int i = 0; i < 48; i++) {
        p = ro + D * d;
        s = map(p, lights, T) * 0.8;
        d += s;

        fragColor += lights + 1.0 / max(s, 0.01);

        if (d > 100.0) break;
    }

    // normal (tetrahedron)
    float h = 0.005;
    float2 k = float2(1.0, -1.0);

    float3 n = normalizeSafe(
        k.xyy * map(p + k.xyy * h, lights, T) +
        k.yyx * map(p + k.yyx * h, lights, T) +
        k.yxy * map(p + k.yxy * h, lights, T) +
        k.xxx * map(p + k.xxx * h, lights, T)
    );

    // diffuse
    fragColor *= (0.1 + max(dot(n, -D), 0.0));

    // reflection (reduced 50 → 24)
    float4 ref = float4(0.0);
    lights = float4(0.0);

    p += n * 0.05;
    D = reflect(D, n);

    for (int i = 0; i < 24; i++) {
        p += D * s;
        s = map(p, lights, T) * 0.8;

        ref += lights + 1.0 / max(s, 0.01);

        if (s < 0.001) break;
    }

    fragColor += fragColor * ref;

    fragColor = tanh(
        fragColor / 1e9 *
        exp(float4(10.0, 2.0, 1.0, 0.0) * d / 500.0)
    );

    return float4(fragColor.rgb, 1.0);
}

