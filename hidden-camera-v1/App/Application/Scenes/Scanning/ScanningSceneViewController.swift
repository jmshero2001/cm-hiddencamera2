import UIKit
import Combine

final class ScanningSceneViewController: UIViewController {
    
    var showScanning: (() -> ())?
    private let presenter: ScanningPresenter
    
    private var progressTimer: Timer?
    private var progress: Float = 0.0
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "start"), for: .normal)
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    private let tapToStart = UIImageView(image: UIImage(named: "inProgress"))
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [startButton, tapToStart])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = #colorLiteral(red: 0.0862745098, green: 0.3725490196, blue: 1, alpha: 1)
        progress.trackTintColor = #colorLiteral(red: 0.3254901961, green: 0.3254901961, blue: 0.3294117647, alpha: 1)
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        progress.setProgress(0.0, animated: false)
        return progress
    }()
    
    init(presenter: ScanningPresenter) {
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
        startProgressAnimation()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#181821")
        
        view.addSubview(stackView)
        view.addSubview(closeButton)
        view.addSubview(progressView)
        
        stackView.centerInSuperview()
        
        closeButton.trailingToSuperview(offset: 16)
        closeButton.topToSuperview(offset: 13, usingSafeArea: true)
        
        progressView.topToBottom(of: stackView, offset: 20)
        progressView.leading(to: stackView)
        progressView.trailing(to: stackView)
        progressView.height(6)
        
    }
    
    
    private func addActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        progressTimer?.invalidate()
        presenter.stopScanWifi()
        presenter.stopScanBluetooth()
        dismiss(animated: true)
    }
    
    private func startProgressAnimation() {
        progress = 0.0
        progressView.setProgress(progress, animated: false)
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.progress += 0.05 / 5.0
            self.progressView.setProgress(self.progress, animated: true)
            
            if self.progress >= 1.0 {
                timer.invalidate()
            }
        }
    }
}
