//
//  ViewController.swift
//  RayBreak
//
//  Created by Thejas K on 29/07/24.
//

import UIKit
import MetalKit

enum Colors {
    static let wenderlichGreen = MTLClearColor(red: 0.0, green: 0.4, blue: 0.21, alpha: 1.0)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var metalView: MTKView!
    
    var renderer : Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWithDevice()
    }
    
    func initWithDevice() {
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.framebufferOnly = true
        metalView.clearColor = Colors.wenderlichGreen
        
        metalView.delegate = self
        renderer = Renderer(device: metalView.device, delegate: self)
    }
    
}

extension ViewController : MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable , let descriptor = view.currentRenderPassDescriptor else {return}
        
        renderer?.drawMetalView(drawable: drawable, descriptor: descriptor,view: view)
        
    }
    
    
}

extension ViewController : RendererProtocol {
    
    func setupRenderPassdescriptor(view: MTKView) {
        
    }
    
    func setupRenderSceneDescriptor(view: MTKView) {
        
    }
    
    func setupRenderLightSourceDescriptor(view: MTKView) {
        
    }
    
    func setupGuassionBlurr(view: MTKView) {
        
    }
    
    
}
