import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let vertices: [Vertex] = [
      Vertex(position: SIMD3<Float>(-0.9, -0.5, 0), color: SIMD3<Float>(1, 0, 0)),
      Vertex(position: SIMD3<Float>(-0.6, 0.5, 0), color: SIMD3<Float>(0, 1, 0)),
      Vertex(position: SIMD3<Float>(-0.3, -0.5, 0), color: SIMD3<Float>(0, 0, 1)),
      Vertex(position: SIMD3<Float>(0.0, 0.5, 0), color: SIMD3<Float>(1, 0, 1)),
      Vertex(position: SIMD3<Float>(0.3, -0.5, 0), color: SIMD3<Float>(0, 1, 1)),
      Vertex(position: SIMD3<Float>(0.6, 0.5, 0), color: SIMD3<Float>(1, 1, 0)),
      Vertex(position: SIMD3<Float>(0.9, -0.5, 0), color: SIMD3<Float>(1, 1, 1))
    ]
    
    let indexArray: [UInt16] = [
      0, 1, 2,
      1, 2, 3,
      2, 4, 3,
      3, 4, 5,
      4, 6, 5,
    ]
    
    let vertexBuffer: MTLBuffer
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
        
        let vertextBufferLength = MemoryLayout<Vertex>.stride * vertices.count
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertextBufferLength, options: [])!
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
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        
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
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
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
