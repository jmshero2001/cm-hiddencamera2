import UIKit

final class SettingsSceneViewController: UIViewController {
    
    private let presenter: SettingsScenePresenter
    
    private let printerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "printer"), for: .normal)
        return button
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.bold(32)
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    init(presenter: SettingsScenePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupOptions()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#181821")
        
        view.addSubview(printerButton)
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        titleLabel.leadingToSuperview(offset: 16)
        titleLabel.topToSuperview(offset: 13, usingSafeArea: true)
        
        printerButton.trailingToSuperview(offset: 16)
        printerButton.centerY(to: titleLabel)
        
        stackView.leadingToSuperview(offset: 16)
        stackView.trailingToSuperview(offset: 16)
        stackView.topToBottom(of: printerButton, offset: 24)
        
        printerButton.addTarget(self, action: #selector(printerTapped), for: .touchUpInside)
    }
    
    @objc private func printerTapped() {
        presenter.presentDocumentPicker(delegate: self)
    }
    
    private func setupOptions() {
        SettingsOption.allCases.forEach { option in
            let button = SettingsButton(option: option)
            button.height(63)
            button.tapHandler = {
                self.presenter.optionTapped(option)
            }
            self.stackView.addArrangedSubview(button)
        }
    }
}

extension SettingsSceneViewController: UIDocumentPickerDelegate {
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

class Button: UIButton {
    
    var tapHandler: (() -> ())?
    
    init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func tapped() {
        tapHandler?()
    }
}
