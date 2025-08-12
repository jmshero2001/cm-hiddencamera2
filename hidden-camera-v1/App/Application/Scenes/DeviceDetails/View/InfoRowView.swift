import UIKit

final class InfoRowView: UIView {
    
    private let infoNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.regular(17)
        return label
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFFFFF66").withAlphaComponent(0.4)
        view.height(1)
        return view
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.regular(17)
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoNameLabel, separatorView, infoLabel])
        stack.axis = .horizontal
        stack.spacing = 12
//        stack.contentMode = .center
        stack.alignment = .center
//        stack.distribution = .fillProportionally
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        height(22)
        addSubview(stackView)
        stackView.edgesToSuperview()
    }
    func configure(info: (String, String)) {
        infoNameLabel.text = info.0
        infoLabel.text = info.1
    }
}
