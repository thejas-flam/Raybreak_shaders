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

vertex float4 vertex_shader(const device packed_float3 *vertices [[buffer(0)]] ,constant Constants &constants [[buffer(1)]], unsigned int vid [[vertex_id]]) {
    
    float4 position = float4(vertices[vid],1);
    position.x += constants.animateBy;
    
    return position;
    //return float4(vertices[vid] , 1.0);
}

fragment half4 fragment_shader() {
    return half4(0.75 , 0.35 , 0.1 , 1.0);
}
