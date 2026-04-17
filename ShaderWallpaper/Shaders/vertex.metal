//
//  vertex.metal
//  ShaderWallpaper
//
//  Created by Barnando Akbarto on 17/04/26.
//

#include <metal_stdlib>
#include "common.metal"
using namespace metal;


// =====================
// Vertex shader
// =====================
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


