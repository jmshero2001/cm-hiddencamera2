import UIKit

final class AppButton: UIButton {
    
    private let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let bgView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.semiBold(18)
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        let arrow = UIImageView(image: UIImage(named: "arrowRight"))
        
        label.text = title
        
        backgroundColor = UIColor(hex: "#4982FF")
        clipsToBounds = true
        layer.cornerRadius = 32
        
        addSubview(bgView)
        bgView.edgesToSuperview()
        
        addSubview(label)
        label.centerInSuperview()
        
        addSubview(arrow)
        arrow.centerYToSuperview()
        arrow.trailingToSuperview(offset: 8)
        
        addSubview(self.title)
        self.title.centerXToSuperview()
        self.title.centerYToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        label.text = title
    }

    func setAutoRenewable(product: Product?) {
        guard let product else { return }
        label.isHidden = true
        title.attributedText = .attributedStrings(
            alignment: .center,
            (product.isTrial ? "3-day Free Trial then \(product.product.skProduct?.localizedPrice ?? .empty)" : "Subscribe for \(product.priceAndPeriod)", [
                .foregroundColor: UIColor(hex: "#FFFFFF"),
                .font: Fonts.medium(16)
            ]),
            ("\nAuto renewable. Cancel anytime", [
                .foregroundColor: UIColor(hex: "#FFFFFF").withAlphaComponent(0.5),
                .font: Fonts.regular(14)
            ])
        )
    }
}

extension NSAttributedString {
    static func attributedStrings(lineSpacing: CGFloat = 0,
                                  alignment: NSTextAlignment = .left,
                                  _ strings: (String, [NSAttributedString.Key: Any])...) -> NSAttributedString {
        let combinedString = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineSpacing
        paragraphStyle.alignment = alignment
        
        for stringTuple in strings {
            var attributes = stringTuple.1
            attributes[.paragraphStyle] = paragraphStyle
            
            let attributedString = NSAttributedString(string: stringTuple.0, attributes: attributes)
            combinedString.append(attributedString)
        }

        return combinedString
    }
}
