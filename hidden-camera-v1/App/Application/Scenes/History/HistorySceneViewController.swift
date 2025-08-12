import UIKit
import Combine
import FittedSheets

final class HistorySceneViewController: UIViewController {
    
    private let presenter: HistoryScenePresenter
    private var lastUsedSheet: SheetViewController?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 63)
        layout.minimumInteritemSpacing = 12
        return layout
    }()
    
    private let printerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "printer"), for: .normal)
        return button
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.bold(32)
        return label
    }()
    private let noDevices = UIImageView(image: UIImage(named: "historyEmpty"))
    private let goToScannerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go To Device Scanner", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(18)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 35
        button.backgroundColor = UIColor(hex: "#4982FF")
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noDevices])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(FoundDeviceCell.self, forCellWithReuseIdentifier: "FoundDeviceCell")
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    init(presenter: HistoryScenePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadDevices()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        presenter.savedDevicesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                guard let self = self else { return }
                self.collectionView.reloadData()

                if devices.isEmpty {
                    self.goToScannerButton.isHidden = false
                    self.stackView.isHidden = false
                    self.collectionView.isHidden = true
                } else {
                    self.goToScannerButton.isHidden = true
                    self.stackView.isHidden = true
                    self.collectionView.isHidden = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#181821")
        
        view.addSubview(printerButton)
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        view.addSubview(collectionView)
        
        titleLabel.leadingToSuperview(offset: 16)
        titleLabel.topToSuperview(offset: 13, usingSafeArea: true)
        
        printerButton.trailingToSuperview(offset: 16)
        printerButton.centerY(to: titleLabel)
        
        goToScannerButton.height(68)
        stackView.centerInSuperview()
        
        printerButton.addTarget(self, action: #selector(printerTapped), for: .touchUpInside)
        
        goToScannerButton.addTarget(self, action: #selector(goToScannerButtonTapped), for: .touchUpInside)
        
        collectionView.topToBottom(of: printerButton, offset: 20)
        collectionView.leadingToSuperview()
        collectionView.trailingToSuperview()
        collectionView.bottomToSuperview(usingSafeArea: true)
    }
    
    @objc private func goToScannerButtonTapped() {
    }
    
    @objc private func printerTapped() {
        presenter.presentDocumentPicker(delegate: self)
    }
    
    private func showDeviceDetails(withDevice device: GeneralDevice) {
        
        let container = UIViewController()
        container.modalPresentationStyle = .overCurrentContext
        present(container, animated: false)
        
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
        sheet.animateIn(to: container.view, in: container)
        lastUsedSheet = sheet
        
        vc.onDismiss = { [weak self] in
            self?.lastUsedSheet?.animateOut()
            container.dismiss(animated: false)
        }
    }
}

extension HistorySceneViewController: UIDocumentPickerDelegate {
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
    private func checkPremium() -> Bool {
        guard ApphudService.global.hasPremium else { presenter.showPaywall(); return false }
        return true
    }
}

extension HistorySceneViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.savedDevicesSubject.value.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoundDeviceCell", for: indexPath) as! FoundDeviceCell
        cell.configure(device: presenter.savedDevicesSubject.value[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard checkPremium() else { return }
        showDeviceDetails(withDevice: presenter.savedDevicesSubject.value[indexPath.row])
    }
}
