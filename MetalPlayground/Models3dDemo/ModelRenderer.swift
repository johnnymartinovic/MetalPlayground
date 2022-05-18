import Foundation
import MetalKit

class ModelRenderer: NSObject {
    
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let train: Model
    let tree: Model
    
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
        train.transform.position = [0.4, 0, 0]
        train.transform.scale = 0.5
        
        tree = Model(name: "treefir")
        tree.transform.position = [-0.6, 0, 0.3]
        tree.transform.scale = 0.5
        
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
        
        var viewTransform = Transform()
        viewTransform.position.y = 1.0
        
        var viewMatrix = viewTransform.matrix.inverse
        commandEncoder.setVertexBytes(
            &viewMatrix,
            length: MemoryLayout<float4x4>.stride,
            index: 22)
        
        let models = [tree, train]
        for model in models {
            var modelMatrix = model.transform.matrix
            commandEncoder.setVertexBytes(&modelMatrix,
                                          length: MemoryLayout<float4x4>.stride,
                                          index: 21)
            
            for mtkMesh in model.mtkMeshes {
                for vertexBuffer in mtkMesh.vertexBuffers {
                    commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                    
                    var color = 0
                    
                    for submesh in mtkMesh.submeshes {
                        commandEncoder.setVertexBytes(&color, length: MemoryLayout<Int>.stride, index: 11)
                        
                        commandEncoder.drawIndexedPrimitives(
                            type: .triangle,
                            indexCount: submesh.indexCount,
                            indexType: submesh.indexType,
                            indexBuffer: submesh.indexBuffer.buffer,
                            indexBufferOffset: submesh.indexBuffer.offset)
                        
                        color += 1
                    }
                }
            }
        }
        
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
