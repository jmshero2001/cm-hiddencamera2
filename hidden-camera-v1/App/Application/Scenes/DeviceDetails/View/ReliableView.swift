import UIKit

final class ReliableView: UIView {
    
    private let reliableLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium(16)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        
        
   
    }
    
    func isReliable(_ isReliable: Bool, isForCell: Bool = false) {
        layer.cornerRadius = isForCell ? 12 :  16
        addSubview(reliableLabel)
        reliableLabel.edgesToSuperview(insets: .init(top: isForCell ? 3 :  6, left: isForCell ? 6 :  16, bottom: isForCell ? 3 :  6, right: isForCell ? 6 :  16))
        
        reliableLabel.text = isReliable ? "Secure device" : "Unreliable device"
        reliableLabel.font = isForCell ? Fonts.medium(12) : Fonts.medium(16)
        reliableLabel.textColor = isReliable ? UIColor(hex: "#18FF37") : UIColor(hex: "#FF181C")
        backgroundColor = isReliable ? UIColor(hex: "#18FF37").withAlphaComponent(0.1) : UIColor(hex: "#FF181C").withAlphaComponent(0.1)
    }
}
