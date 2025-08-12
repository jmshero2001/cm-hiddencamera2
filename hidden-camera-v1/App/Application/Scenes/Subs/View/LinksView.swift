import UIKit

final class LinksView: UIView {
    
    private let byContinueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.5)
        label.font = Fonts.regular(12)
        label.text = "by continue you agree to"
        return label
    }()
    private let andLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.3)
        label.font = Fonts.regular(12)
        label.text = "and"
        return label
    }()
    let termsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Terms of Service", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF").withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = Fonts.bold(12)
        return button
    }()
    let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF").withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = Fonts.bold(12)
        return button
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [termsButton, andLabel, privacyButton])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .equalSpacing
        return stack
    }()
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [byContinueLabel, hStack])
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()
    init() {
        super.init(frame: .zero)
        alpha = 0.0
        addSubviews()
        configureViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        
        addSubview(vStack)
    }
    
    private func configureViewLayout() {
        vStack.height(40)
        vStack.edgesToSuperview()
    }
}
