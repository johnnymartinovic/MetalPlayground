//
//  Model.swift
//  MetalPlayground
//
//  Created by Ivan Martinović on 19.04.2022..
//

import Foundation
import MetalKit

class Model {
    
    let mdlMeshes: [MDLMesh]
    let mtkMeshes: [MTKMesh]
    
    init(name: String) {
        let assetUrl = Bundle.main.url(forResource: name, withExtension: "obj")
        let allocator = MTKMeshBufferAllocator(device: ModelRenderer.device)
        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor()
        let asset = MDLAsset(
            url: assetUrl,
            vertexDescriptor: vertexDescriptor,
            bufferAllocator: allocator)
        
        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: ModelRenderer.device)
        
        self.mdlMeshes = mdlMeshes
        self.mtkMeshes = mtkMeshes
    }
}
