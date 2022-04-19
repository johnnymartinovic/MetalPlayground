import Foundation
import MetalKit

class ModelRenderer: NSObject {
    
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let train: Model
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        ModelRenderer.device = device
        self.commandQueue = commandQueue
        ModelRenderer.library = device.makeDefaultLibrary()!
        pipelineState = ModelRenderer.createPipelineState()
        
        train = Model(name: "train")
        
        super.init()
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        // pipeline state properties
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = ModelRenderer.library.makeFunction(name: "model_vertex_main")
        let fragmentFunction = ModelRenderer.library.makeFunction(name: "model_fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultModelVertexDescriptor()
        
        return try! ModelRenderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension ModelRenderer: MTKViewDelegate {
    
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
        
        
        // draw call
        for mtkMesh in train.mtkMeshes {
            for vertexBuffer in mtkMesh.vertexBuffers {
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                
                for submesh in mtkMesh.submeshes {
                    commandEncoder.drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: submesh.indexCount,
                        indexType: submesh.indexType,
                        indexBuffer: submesh.indexBuffer.buffer,
                        indexBufferOffset: submesh.indexBuffer.offset)
                }
            }
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
