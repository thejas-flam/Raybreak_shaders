//
//  Shader.metal
//  RayBreak
//
//  Created by Thejas K on 30/07/24.
//

#include <metal_stdlib> 
using namespace metal;

struct Constants {
    float animateBy;
};

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertex_shader(const VertexIn vertexIn [[stage_in]]) {
    
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.color = vertexIn.color;
    
    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return half4(vertexIn.color);
}
