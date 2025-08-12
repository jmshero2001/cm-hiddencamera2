import UIKit

final class DeviceNotFoundViewController: UIViewController {
    
    var showScanning: (() -> ())?
    
    private let noDevices = UIImageView(image: UIImage(named: "noDevices"))
    private let tryAgainButton: UIButton = {
        let button = UIButton()
        button.setTitle("Try Again", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(18)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 35
        button.backgroundColor = UIColor(hex: "#4982FF")
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noDevices, tryAgainButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addActions()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#181821")
        
        view.addSubview(stackView)
        view.addSubview(closeButton)
        
        tryAgainButton.height(68)
        stackView.centerInSuperview()
        
        closeButton.trailingToSuperview(offset: 16)
        closeButton.topToSuperview(offset: 13, usingSafeArea: true)
    }
    
    private func addActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        tryAgainButton.addTarget(self, action: #selector(tryAgain), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    @objc private func tryAgain() {
        dismiss(animated: true) {
            self.showScanning?()
        }
    }
}
