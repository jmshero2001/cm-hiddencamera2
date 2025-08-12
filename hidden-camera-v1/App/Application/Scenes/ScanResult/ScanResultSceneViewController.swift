import UIKit
import FittedSheets

final class ScanResultSceneViewController: UIViewController {
    var showScanning: (() -> ())?
    private var lastUsedSheet: SheetViewController?
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 63)
        layout.minimumInteritemSpacing = 12
        return layout
    }()
    
    private let presenter: ScanResultScenePresenter
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scanning result"
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.semiBold(19)
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.setTitle("Refresh", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(18)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 35
        button.backgroundColor = UIColor(hex: "#4982FF")
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(FoundDeviceCell.self, forCellWithReuseIdentifier: "FoundDeviceCell")
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    init(presenter: ScanResultScenePresenter) {
        self.presenter = presenter
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
        view.backgroundColor = UIColor(hex: "#181821")
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(collectionView)
        view.addSubview(refreshButton)
    
        
        titleLabel.centerXToSuperview()
        titleLabel.topToSuperview(offset: 13, usingSafeArea: true)
        
        closeButton.trailingToSuperview(offset: 16)
        closeButton.centerY(to: titleLabel)
        
        refreshButton.leadingToSuperview(offset: 16)
        refreshButton.trailingToSuperview(offset: 16)
        refreshButton.bottomToSuperview(offset: -20, usingSafeArea: true)
        refreshButton.height(68)
        
        collectionView.topToBottom(of: closeButton, offset: 20)
        collectionView.leadingToSuperview()
        collectionView.trailingToSuperview()
        collectionView.bottomToSuperview()
    }
    
    private func addActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    @objc private func refreshTapped() {        
        dismiss(animated: true) {
            self.showScanning?()
        }
    }
    
    private func showDeviceDetails(withDevice device: GeneralDevice) {
        let vc = DeviceDetailsViewController(device: device)
        
        let sheet = SheetViewController(
            controller: vc,
            sizes: [
                .fixed(390)
            ],
            options: SheetOptions(
                pullBarHeight: .zero,
                useInlineMode: true
            )
        )
        sheet.allowPullingPastMaxHeight = false
        sheet.allowPullingPastMinHeight = false
        sheet.autoAdjustToKeyboard = false
        sheet.overlayColor = UIColor(hex: "#000000").withAlphaComponent(0.5)
        sheet.cornerRadius = 16
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = true
        sheet.allowGestureThroughOverlay = false
        sheet.animateIn(to: view, in: self)
        lastUsedSheet = sheet
        
        vc.onDismiss = { [weak self] in
            self?.lastUsedSheet?.animateOut()
        }
    }
    
    private func checkPremium() -> Bool {
        guard ApphudService.global.hasPremium else { presenter.showPaywall(); return false }
        return true
    }
}

extension ScanResultSceneViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.combinedDevices.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoundDeviceCell", for: indexPath) as! FoundDeviceCell
        cell.configure(device: presenter.combinedDevices[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard checkPremium() else { return }
        showDeviceDetails(withDevice: presenter.combinedDevices[indexPath.row])
    }
}
