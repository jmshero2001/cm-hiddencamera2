import UIKit
import TinyConstraints

final class HomeSceneViewController: UIViewController {
    
    private var typeOfScanning: TypeOfScanning = .wifi
    
    private let presenter: HomeScenePresenter
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Device Scanner"
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.bold(32)
        return label
    }()
    
    private let printerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "printer"), for: .normal)
        return button
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "start"), for: .normal)
        return button
    }()
    
    private let switcher = WifiBluetoothSwitcher()
    
    private let tapToStart = UIImageView(image: UIImage(named: "tapToStart"))
    private let or = UIImageView(image: UIImage(named: "or"))
    
    private let scanButton: UIButton = {
        let button = UIButton()
        button.setTitle("Find using Camera", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(18)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 35
        button.backgroundColor = UIColor(hex: "#4982FF")
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tapToStart, or, scanButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    init(presenter: HomeScenePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switcher.wifiTapHangler = { [weak self] in
            self?.typeOfScanning = .wifi
        }
        
        switcher.bluetoothTapHangler = { [weak self] in
            self?.typeOfScanning = .bluetooth
        }
        
        setupUI()
        addActions()
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowGlobalPaywall"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.presenter.showPaywall()
            }
        }
    }
    
    private func setupUI() {
        
        or.contentMode = .scaleAspectFit
        tapToStart.contentMode = .scaleAspectFit
        
        view.backgroundColor = UIColor(hex: "#181821")
        
        view.addSubview(titleLabel)
        view.addSubview(printerButton)
        view.addSubview(switcher)
        view.addSubview(startButton)
        view.addSubview(stackView)
        
        titleLabel.leadingToSuperview(offset: 16)
        titleLabel.topToSuperview(offset: 13, usingSafeArea: true)
        
        printerButton.trailingToSuperview(offset: 16)
        printerButton.centerY(to: titleLabel)
        
        switcher.centerXToSuperview()
        switcher.topToBottom(of: printerButton, offset: 14)
        switcher.height(38)
        switcher.width(208)
        
        startButton.centerXToSuperview()
        startButton.topToBottom(of: switcher, offset: 32)
        
        scanButton.height(68)
        
        stackView.leadingToSuperview(offset: 30)
        stackView.trailingToSuperview(offset: 30)
        stackView.topToBottom(of: startButton, offset: 32)
        stackView.bottomToSuperview(offset: -41, usingSafeArea: true)
    }
    
    private func addActions() {
        scanButton.addTarget(self, action: #selector(scanTapped), for: .touchUpInside)
        printerButton.addTarget(self, action: #selector(printerTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }
    
    @objc private func printerTapped() {
        presenter.presentDocumentPicker(delegate: self)
    }
    
    @objc private func scanTapped() {
        guard checkPremium() else { return }
        let vc = ScannerSceneViewController()
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true)
    }
    private func checkPremium() -> Bool {
        guard ApphudService.global.hasPremium else { presenter.showPaywall(); return false }
        return true
    }
    @objc private func startTapped() {
        if ApplicationCacheService.shared.isFreeContentPassed {
            guard checkPremium() else { return }
        }
        guard let navigationController else { return }
        ApplicationCacheService.shared.setFreeContentPassed()
        let presenter = ScanningPresenter(navigationController: navigationController, typeOfScanning: typeOfScanning)
        let vc = ScanningSceneViewController(presenter: presenter)
        presenter.showScanning = startTapped
        vc.showScanning = startTapped
        vc.modalPresentationStyle = .overCurrentContext
        navigationController.present(vc, animated: true)
    }
}

extension HomeSceneViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
                
        let id = UUID().uuidString
        let fileManager = FileManager.default
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let destinationURL = documentsDirectory.appendingPathComponent("\(id)" + url.lastPathComponent)
        
        do {
            try fileManager.copyItem(at: url, to: destinationURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                DispatchQueue.main.async {
                    let vc = PrinterSceneViewController()
                    vc.setupWebView(with: url)
                    vc.modalPresentationStyle = .overCurrentContext
                    self?.navigationController?.present(vc, animated: true)
                }
            }
        } catch {
            print("DEBUG [error]: \(error)")
        }
    }
}
