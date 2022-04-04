//
//  Shaders.metal
//  MetalPlayground
//
//  Created by Ivan Martinović on 04.04.2022..
//

#include <metal_stdlib>
using namespace metal;

/*
constant float3 color[6] = {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1),
    float3(0, 0, 1),
    float3(0, 1, 0),
    float3(1, 0, 1),
};
 */

struct VertexIn {
    float3 position;
    float3 color;
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexOut vertex_main(device const VertexIn *vertexBuffer [[buffer(0)]],
                             uint vertexId [[vertex_id]]) {
  
  VertexOut out {
    .position = float4(vertexBuffer[vertexId].position, 1),
    .color = vertexBuffer[vertexId].color
  };
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
  return float4(in.color, 1);
}
