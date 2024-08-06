//
//  Renderer.swift
//  RayBreak
//
//  Created by Thejas K on 30/07/24.
//

import Foundation
import MetalKit
import Metal
import simd

class Renderer : NSObject {
    
    var device : MTLDevice?
    var pipelineState : MTLRenderPipelineState?
    var commandQueue : MTLCommandQueue?
    var vertexBuffer : MTLBuffer?
    var indexBuffer : MTLBuffer?
    
    var vertices : [Vertex] = [
        Vertex(position: SIMD3<Float>(-1.0, 1.0, 0.0), color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0)), // red
        Vertex(position: SIMD3<Float>(-1.0, -1.0, 0.0), color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0)), // green
        Vertex(position: SIMD3<Float>(1.0, -1.0, 0.0), color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0)), // blue
        Vertex(position: SIMD3<Float>(1.0, 1.0, 0.0), color: SIMD4<Float>(1.0, 0.5, 0.0, 1.0)) // orange
    ]
    
    var indices : [UInt16] = [
        0 , 1 , 2,
        2 , 3 , 0
    ]
    
    struct Constants {
        var animateBy : Float = 0.0
    }
    
    var constants = Constants()
    
    var time : Float = 0
    
    init(device: MTLDevice? = nil) {
        self.device = device
        self.commandQueue = self.device?.makeCommandQueue()
        super.init()
        buildModel()
        setupPipelineState()
    }
    
    func buildModel() {
        
        let size = MemoryLayout<Vertex>.size * vertices.count
        
        vertexBuffer = device?.makeBuffer(bytes: vertices, length: size, options: [])
        
        indexBuffer = device?.makeBuffer(bytes: indices, 
                                         length: indices.count * MemoryLayout<UInt16>.size ,
                                         options: [])
        
    }
    
    func setupPipelineState() {
        
        let library = device?.makeDefaultLibrary()
        
        let vertex_shader = library?.makeFunction(name: "vertex_shader")
        let fragment_shader = library?.makeFunction(name: "fragment_shader")
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex_shader
        descriptor.fragmentFunction = fragment_shader
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.depthAttachmentPixelFormat = .depth32Float
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        descriptor.vertexDescriptor = vertexDescriptor
        
        do {
            pipelineState = try device?.makeRenderPipelineState(descriptor: descriptor)
        }
        
        catch {
            print(error)
        }
    }
    
    func drawMetalView(drawable:CAMetalDrawable,descriptor:MTLRenderPassDescriptor,view:MTKView) {
        
        guard let pipelineState = self.pipelineState , let indexBuffer = indexBuffer else {return}
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        time += 1 / Float(view.preferredFramesPerSecond)
        
        constants.animateBy = abs(sin(time) / 2 + 0.5)
        
        commandEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle,
                                              indexCount: indices.count,
                                              indexType: .uint16,
                                              indexBuffer: indexBuffer,
                                              indexBufferOffset: 0)
        
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
}

extension Renderer : MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable , let description = view.currentRenderPassDescriptor , let state = self.pipelineState , let indexBuffer = indexBuffer else {return}
        
        commandQueue = device?.makeCommandQueue()
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: description)
        
        commandEncoder?.setRenderPipelineState(state)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        time += 1 / Float(view.preferredFramesPerSecond)
        
        constants.animateBy = abs(sin(time) / 2 + 0.5)
        
        //print("Renderer_draw : \(constants.animateBy)")
        
        commandEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0) 
        
        //commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
    
}
