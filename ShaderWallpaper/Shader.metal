//
//  Shader.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 21/01/26.
//
#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// Vertex shader - creates fullscreen quad
vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
    VertexOut out;
    
    float2 positions[6] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2(-1.0,  1.0),
        float2( 1.0, -1.0),
        float2( 1.0,  1.0)
    };
    
    float2 pos = positions[vertexID];
    out.position = float4(pos, 0.0, 1.0);
    out.texCoord = (pos + 1.0) * 0.5;
    out.texCoord.y = 1.0 - out.texCoord.y;
    
    return out;
}

// =============================================================================
// SHADER 1: BALATRO (Original)
// =============================================================================

#define SPIN_ROTATION -2.0
#define SPIN_SPEED 7.0
#define OFFSET float2(0.0)
#define COLOUR_1 float4(0.871, 0.267, 0.231, 1.0)
#define COLOUR_2 float4(0.0, 0.42, 0.706, 1.0)
#define COLOUR_3 float4(0.086, 0.137, 0.145, 1.0)
#define CONTRAST 3.5
#define LIGHTING 0.4
#define SPIN_AMOUNT 0.25
#define PIXEL_FILTER 745.0
#define SPIN_EASE 1.0
#define IS_ROTATE false

float4 balatroEffect(float2 screenSize, float2 screen_coords, float iTime) {
    float pixel_size = length(screenSize) / PIXEL_FILTER;
    float2 uv = (floor(screen_coords * (1.0 / pixel_size)) * pixel_size - 0.5 * screenSize) / length(screenSize) - OFFSET;
    float uv_len = length(uv);
    
    float speed = (SPIN_ROTATION * SPIN_EASE * 0.2);
    if (IS_ROTATE) {
        speed = iTime * speed;
    }
    speed += 302.2;
    
    float new_pixel_angle = atan2(uv.y, uv.x) + speed - SPIN_EASE * 20.0 * (1.0 * SPIN_AMOUNT * uv_len + (1.0 - 1.0 * SPIN_AMOUNT));
    float2 mid = (screenSize / length(screenSize)) / 2.0;
    uv = (float2((uv_len * cos(new_pixel_angle) + mid.x), (uv_len * sin(new_pixel_angle) + mid.y)) - mid);
    
    uv *= 30.0;
    speed = iTime * SPIN_SPEED;
    float2 uv2 = float2(uv.x + uv.y);
    
    for (int i = 0; i < 5; i++) {
        uv2 += sin(max(uv.x, uv.y)) + uv;
        uv += 0.5 * float2(cos(5.1123314 + 0.353 * uv2.y + speed * 0.131121), sin(uv2.x - 0.113 * speed));
        uv -= 1.0 * cos(uv.x + uv.y) - 1.0 * sin(uv.x * 0.711 - uv.y);
    }
    
    float contrast_mod = (0.25 * CONTRAST + 0.5 * SPIN_AMOUNT + 1.2);
    float paint_res = min(2.0, max(0.0, length(uv) * 0.035 * contrast_mod));
    float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - paint_res));
    float c2p = max(0.0, 1.0 - contrast_mod * abs(paint_res));
    float c3p = 1.0 - min(1.0, c1p + c2p);
    float light = (LIGHTING - 0.2) * max(c1p * 5.0 - 4.0, 0.0) + LIGHTING * max(c2p * 5.0 - 4.0, 0.0);
    
    return (0.3 / CONTRAST) * COLOUR_1 + (1.0 - 0.3 / CONTRAST) * (COLOUR_1 * c1p + COLOUR_2 * c2p + float4(c3p * COLOUR_3.rgb, c3p * COLOUR_1.a)) + light;
}

fragment float4 balatroShader(VertexOut in [[stage_in]],
                              constant float *uniforms [[buffer(0)]]) {
    float iTime = uniforms[0];
    float2 iResolution = float2(uniforms[1], uniforms[2]);
    float2 fragCoord = in.texCoord * iResolution;
    
    return balatroEffect(iResolution, fragCoord, iTime);
}

