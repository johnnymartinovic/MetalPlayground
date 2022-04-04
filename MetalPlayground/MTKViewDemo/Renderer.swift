import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let positionArray: [SIMD4<Float>] = [
        SIMD4<Float>(-0.9, -0.5, 0, 1),
        SIMD4<Float>(-0.6, 0.5, 0, 1),
        SIMD4<Float>(-0.3, -0.5, 0, 1),
        SIMD4<Float>(0.0, 0.5, 0, 1),
        SIMD4<Float>(0.3, -0.5, 0, 1),
        SIMD4<Float>(0.6, 0.5, 0, 1),
        SIMD4<Float>(0.9, -0.5, 0, 1),
    ]
    
    let colorArray: [SIMD3<Float>] = [
        SIMD3<Float>(1, 0, 0),
        SIMD3<Float>(0, 1, 0),
        SIMD3<Float>(0, 0, 1),
        SIMD3<Float>(1, 0, 1),
        SIMD3<Float>(0, 1, 1),
        SIMD3<Float>(1, 1, 0),
        SIMD3<Float>(1, 1, 1),
    ]
    
    let indexArray: [UInt16] = [
      0, 1, 2,
      1, 2, 3,
      2, 4, 3,
      3, 4, 5,
      4, 6, 5,
    ]
    
    let positionBuffer: MTLBuffer
    let colorBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        pipelineState = Renderer.createPipelineState()
        
        let positionLength = MemoryLayout<SIMD4<Float>>.stride * positionArray.count
        positionBuffer = device.makeBuffer(bytes: positionArray, length: positionLength, options: [])!
        let colorLength = MemoryLayout<SIMD3<Float>>.stride * colorArray.count
        colorBuffer = device.makeBuffer(bytes: colorArray, length: colorLength, options: [])!
        let indexBufferLength = MemoryLayout<UInt16>.stride * indexArray.count
        indexBuffer = device.makeBuffer(bytes: indexArray, length: indexBufferLength, options: [])!
        
        super.init()
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        // pipeline state properties
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // do nothing
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        commandEncoder.setRenderPipelineState(pipelineState)
        
        commandEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        // draw call
        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indexArray.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0)
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
