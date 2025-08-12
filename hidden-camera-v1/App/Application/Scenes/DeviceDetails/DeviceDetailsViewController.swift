import UIKit

final class DeviceDetailsViewController: UIViewController {
    
    var onDismiss: (() -> ())?
    
    private let device: GeneralDevice
    
    private let reliableView = ReliableView()
    
    private let topElementView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#C0D4F480").withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.bold(26)
        return label
    }()
    
    private lazy var topHStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, reliableView])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    private let understandButton: UIButton = {
        let button = UIButton()
        button.setTitle("Understand", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(18)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 35
        button.backgroundColor = UIColor(hex: "#4982FF")
        button.height(68)
        return button
    }()
    private lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topHStackView, infoStackView, understandButton])
        stack.axis = .vertical
        stack.spacing = 32
        return stack
    }()
    
    init(device: GeneralDevice) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addActions()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#30303D")
        
        view.addSubview(topElementView)
        view.addSubview(rootStackView)
        
        topElementView.topToSuperview(offset: 6)
        topElementView.centerXToSuperview()
        topElementView.width(30)
        topElementView.height(4)
        
        rootStackView.topToBottom(of: topElementView, offset: 16)
        rootStackView.leadingToSuperview(offset: 16)
        rootStackView.trailingToSuperview(offset: 16)
        rootStackView.bottomToSuperview(offset: -16, usingSafeArea: true)
        
        nameLabel.text = device.name
        
        reliableView.isReliable(device.isSecure)
        fillInfo()
    }
    
    private func addActions() {
        understandButton.addTarget(self, action: #selector(understandTapped), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?()
    }
    
    @objc private func understandTapped() {
        onDismiss?()
    }
    
    private func fillInfo() {
        let ipAdressInfoView = InfoRowView()
        let macInfoView = InfoRowView()
        let hostNameInfoView = InfoRowView()
        
        ipAdressInfoView.configure(info: ("IP Address", device.ip))
        macInfoView.configure(info: ("Mac Address", "02:00:00:00:00:00"))
        hostNameInfoView.configure(info: ("Hostname", device.name))
        
        infoStackView.addArrangedSubview(ipAdressInfoView)
        infoStackView.addArrangedSubview(macInfoView)
        infoStackView.addArrangedSubview(hostNameInfoView)
    }
}
