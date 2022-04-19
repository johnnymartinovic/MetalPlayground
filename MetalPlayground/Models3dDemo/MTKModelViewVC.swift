import UIKit
import Metal
import MetalKit

class MTKModelViewVC: UIViewController {
    
    var metalView: MTKView = {
        return MTKView()
    }()
    
    var modelRenderer: ModelRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(metalView)
        metalView.frame = view.frame
        NSLayoutConstraint.activate([
            metalView.topAnchor.constraint(equalTo: view.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        modelRenderer = ModelRenderer(view: metalView)
        metalView.device = ModelRenderer.device
        metalView.delegate = modelRenderer
        
        metalView.clearColor = MTLClearColor(red: 1.0,
                                             green: 1.0,
                                             blue: 0.8,
                                             alpha: 1.0)
    }
}
