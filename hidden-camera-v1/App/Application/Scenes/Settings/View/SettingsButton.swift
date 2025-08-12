import UIKit

final class SettingsButton: Button {
    
    private let title: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.semiBold(16)
        return label
    }()
    private let chevronImage = UIImageView(image: UIImage(named: "chevronRight"))
    
    init(option: SettingsOption) {
        super.init()
        
        backgroundColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.1)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.12).cgColor
        
        title.text = option.title
        
        addSubview(title)
        title.centerYToSuperview()
        title.leadingToSuperview(offset: 20)
        
        addSubview(chevronImage)
        chevronImage.centerYToSuperview()
        chevronImage.trailingToSuperview(offset: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SettingsOption: String, CaseIterable {
    case feedback
    case terms
    case privacy
    case rate
    case share
    
    var title: String {
        switch self {
        case .privacy:
            "Privacy policy"
        case .terms:
            "Terms of use"
        case .rate:
            "Rate us"
        case .feedback:
            "Contact us"
        case .share:
            "Share app with friends"
        }
    }
}
