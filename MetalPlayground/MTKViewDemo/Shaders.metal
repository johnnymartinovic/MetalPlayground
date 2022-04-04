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

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float3 color;
};

vertex VertexOut vertex_main(device const float4 *positionBuffer [[buffer(0)]],
                             device const float3 *colorBuffer [[buffer(1)]],
                             uint vertexId [[vertex_id]]) {
  
  VertexOut out {
    .position = positionBuffer[vertexId],
    .color = colorBuffer[vertexId]
  };
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
  return float4(in.color, 1);
}
