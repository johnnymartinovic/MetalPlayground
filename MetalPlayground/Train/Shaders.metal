//
//  Shaders.metal
//  MetalPlayground
//
//  Created by Ivan Martinović on 04.04.2022..
//

#include <metal_stdlib>
using namespace metal;

constant float3 color[6] = {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1),
    float3(0, 0, 1),
    float3(0, 1, 0),
    float3(1, 0, 1),
};

struct ModelVertexIn {
    float4 position [[attribute(0)]];
};

struct ModelVertexOut {
    float4 position [[position]];
    float3 color;
};

vertex ModelVertexOut model_vertex_main(ModelVertexIn vertexBuffer [[stage_in]],
                                        constant uint &colorIndex [[buffer(11)]]) {
    
    ModelVertexOut out {
        .position = vertexBuffer.position,
        .color = color[colorIndex]
    };
    out.position.y -= 0.5;
    return out;
}

fragment float4 model_fragment_main(ModelVertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}
