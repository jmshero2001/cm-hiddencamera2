import UIKit

final class WifiBluetoothSwitcher: UIView {
    
    var wifiTapHangler: (() -> ())?
    var bluetoothTapHangler: (() -> ())?
    
    private let wifiButton: UIButton = {
        let button = UIButton()
        button.setTitle("Wi-Fi", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(16)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor(hex: "#4982FF")
        return button
    }()
    
    private let bluetoothButton: UIButton = {
        let button = UIButton()
        button.setTitle("Bluetooth", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(16)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [wifiButton, bluetoothButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.1)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.12).cgColor
        
        addSubview(stackView)
        
        stackView.edgesToSuperview(insets: .init(top: 4, left: 4, bottom: 4, right: 4))
        
        wifiButton.addTarget(self, action: #selector(wifiTapped), for: .touchUpInside)
        bluetoothButton.addTarget(self, action: #selector(bluetoothTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func wifiTapped() {
        wifiButton.backgroundColor = UIColor(hex: "#4982FF")
        bluetoothButton.backgroundColor = .clear
        wifiTapHangler?()
    }
    @objc private func bluetoothTapped() {
        wifiButton.backgroundColor = .clear
        bluetoothButton.backgroundColor = UIColor(hex: "#4982FF")
        bluetoothTapHangler?()
    }
}
