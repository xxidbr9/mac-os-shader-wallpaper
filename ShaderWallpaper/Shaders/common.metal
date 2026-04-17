//
//  common.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//

#include <metal_stdlib>
using namespace metal;


// =====================
// Uniforms (MATCH SWIFT EXACTLY)
// =====================
struct Uniforms {
    float time;
    float2 resolution;
    float4 mouse;
};


// =====================
// Shared vertex आउट
// =====================
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

#define PI 3.14159265359

// =====================
// Helpers (expanded macros)
// =====================


static float3 normalizeSafe(float3 v) {
    return normalize(v);
}

static float3 fract3(float3 v) {
    return fract(v);
}

static float length3(float3 v) {
    return length(v);
}

static float3 max3(float3 a, float b) {
    return max(a, float3(b));
}

// rotation (equivalent to m2)
static float2 rot(float2 p, float a) {
    float s = sin(a);
    float c = cos(a);
    return float2(c*p.x - s*p.y, s*p.x + c*p.y);
}
