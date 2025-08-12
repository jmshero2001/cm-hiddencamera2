import UIKit
import AVFoundation

final class ScannerSceneViewController: UIViewController {
    
    private let cameraContainerView = UIView()
    private let overlayView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Device Scanner"
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.bold(26)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var redButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#FF453A")
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor(hex: "#FFFFFF").cgColor
        button.width(40)
        button.height(40)
        button.addTarget(self, action: #selector(redTapped), for: .touchUpInside)
        return button
    }()
    private lazy var blueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#0A84FF")
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor(hex: "#FFFFFF").cgColor
        button.width(40)
        button.height(40)
        button.addTarget(self, action: #selector(blueTapped), for: .touchUpInside)
        return button
    }()
    private lazy var greenButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#32D74B")
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor(hex: "#FFFFFF").cgColor
        button.width(40)
        button.height(40)
        button.addTarget(self, action: #selector(greenTapped), for: .touchUpInside)
        return button
    }()
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [redButton, blueButton, greenButton])
        stack.axis = .horizontal
        stack.spacing = 24
        return stack
    }()
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraContainerView.bounds
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Unable to access camera.")
            return
        }
        
        session.addInput(input)
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        cameraContainerView.layer.insertSublayer(preview, at: 0)
        
        self.captureSession = session
        self.previewLayer = preview
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#30303D")

        view.addSubview(titleLabel)
        titleLabel.centerXToSuperview()
        titleLabel.topToSuperview(offset: 16, usingSafeArea: true)
        
        cameraContainerView.clipsToBounds = true
        cameraContainerView.layer.cornerRadius = 20
        view.addSubview(cameraContainerView)
        cameraContainerView.topToBottom(of: titleLabel, offset: 24)
        cameraContainerView.leadingToSuperview(offset: 16)
        cameraContainerView.trailingToSuperview(offset: 16)
        cameraContainerView.bottomToSuperview(offset: -40)
        
        view.addSubview(buttonsStackView)
        buttonsStackView.centerX(to: cameraContainerView)
        buttonsStackView.bottom(to: cameraContainerView, offset: -30)
        
        overlayView.alpha = 0.5
        overlayView.backgroundColor = UIColor(hex: "#FF453A")
        cameraContainerView.addSubview(overlayView)
        overlayView.edgesToSuperview()
        
        view.addSubview(closeButton)
        closeButton.trailingToSuperview(offset: 16)
        closeButton.centerY(to: titleLabel)
    }
    
    @objc private func redTapped() {
        deselectAll()
        redButton.layer.borderWidth = 4
        overlayView.backgroundColor = UIColor(hex: "#FF453A")
    }
    @objc private func blueTapped() {
        deselectAll()
        blueButton.layer.borderWidth = 4
        overlayView.backgroundColor = UIColor(hex: "#0A84FF")
    }
    @objc private func greenTapped() {
        deselectAll()
        greenButton.layer.borderWidth = 4
        overlayView.backgroundColor = UIColor(hex: "#32D74B")
    }
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    private func deselectAll() {
        buttonsStackView.arrangedSubviews.forEach { $0.layer.borderWidth = 0}
    }
}
