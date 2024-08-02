//
//  Renderer.swift
//  RayBreak
//
//  Created by Thejas K on 30/07/24.
//

import Foundation
import MetalKit
import Metal

protocol RendererProtocol {
    func setupRenderPassdescriptor(view:MTKView)
    func setupRenderSceneDescriptor(view:MTKView)
    func setupRenderLightSourceDescriptor(view:MTKView)
    func setupGuassionBlurr(view:MTKView)
    
}

class Renderer : NSObject {
    
    var metalVeiw : MTKView?
    var device : MTLDevice?
    var pipelineState : MTLRenderPipelineState?
    var commandQueue : MTLCommandQueue?
    var vertexBuffer : MTLBuffer?
    var indexBuffer : MTLBuffer?
    
    let vertexData : [Float] = [
        -1.0 , 1.0 , 0 ,  //v0
        -1.0 , -1.0 , 0 ,  //v1
        1.0 , -1.0 , 0 ,
         1.0 , 1.0 , 0
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
    
    func initMetalView(view:MTKView) {
        view.colorPixelFormat = .bgra8Unorm
        view.framebufferOnly = true
        view.delegate = self
        view.clearColor = Colors.wenderlichGreen
    }
    
    func buildModel() {
        
        let size = MemoryLayout<Float>.stride * vertexData.count
        
        vertexBuffer = device?.makeBuffer(bytes: vertexData, length: size, options: [])
        
        indexBuffer = device?.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * indices.count, options: [])
        
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
        
        do {
            pipelineState = try device?.makeRenderPipelineState(descriptor: descriptor)
        }
        
        catch {
            print(error)
        }
    }
    
    func drawMetalView(drawable:CAMetalDrawable,descriptor:MTLRenderPassDescriptor,view:MTKView) {
        
        guard let pipelineState = self.pipelineState , let indexBuffer = indexBuffer else {return}
        
        commandQueue = device?.makeCommandQueue()
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(indexBuffer, offset: 0, index: 0)
        //commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 6)
        
        time += 1 / Float(view.preferredFramesPerSecond)
        
        constants.animateBy = abs(sin(time) / 2 + 0.5)
        
        commandEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        
        print("Renderer_draw : \(constants.animateBy)")
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
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
