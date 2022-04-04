import UIKit

class MainVC: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    lazy var openTriangleButton: UILabel = {
        let view = createButton(text: "Triangle Demo")
        
        let openTriangleTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.openTriangleDemo))
        view.addGestureRecognizer(openTriangleTapGesture)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainViews()
        
        setupButtons()
    }
    
    private func setupMainViews() {
        title = "Metal Playground"
        view.backgroundColor = UIColor(rgb: 0xF1F5F8)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    private func setupButtons() {
        stackView.addArrangedSubview(openTriangleButton)
    }
    
    private func createButton(text: String) -> UILabel {
        let view = UILabel()
        
        view.text = text
        view.textColor = UIColor(rgb: 0x161E31)
        view.textAlignment = .center
        view.backgroundColor = UIColor(rgb: 0xFFFFFF)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(rgb: 0xD1DAE5).cgColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        return view
    }
    
    @objc private func openTriangleDemo() {
        self.navigationController?.pushViewController(TriangleVC(), animated: true)
    }
}
