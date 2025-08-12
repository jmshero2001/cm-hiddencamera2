import UIKit

struct FoundDevice {
    let id: String
    let name: String
    let ip: String
    let mac: String
    let isReliable: Bool
    let hostName: String
}

final class FoundDeviceCell: UICollectionViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.bold(16)
        return label
    }()
    
    private let ipLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.4)
        label.font = Fonts.medium(12)
        return label
    }()
    
    private let reliableView = ReliableView()
    
    private let chevronImage = UIImageView(image: UIImage(named: "chevronRight"))
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.1)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.12).cgColor
        
        addSubview(nameLabel)
        
        nameLabel.leadingToSuperview(offset: 20)
        nameLabel.topToSuperview(offset: 12)
        addSubview(ipLabel)
        ipLabel.leadingToSuperview(offset: 20)
        ipLabel.topToBottom(of: nameLabel, offset: 2)
        
        addSubview(chevronImage)
        chevronImage.centerYToSuperview()
        chevronImage.trailingToSuperview(offset: 10)
        
        addSubview(reliableView)
        reliableView.centerY(to: nameLabel)
        reliableView.leadingToTrailing(of: nameLabel, offset: 6)
    }
    
    func configure(device: GeneralDevice) {
        nameLabel.text = device.name
        
        if device.source == .wifi {
            ipLabel.text = "Wi-Fi Finder • \(device.ip)"
        } else {
            ipLabel.text = "Bluetooth Finder • \(device.ip)"
        }
        
        reliableView.isReliable(device.isSecure, isForCell: true)
    }
}
