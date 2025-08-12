import UIKit
import WebKit

final class PrinterSceneViewController: UIViewController {
        
    var webView: WKWebView!
 
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
    
    private let printButton: UIButton = {
        let button = UIButton()
        button.setTitle("Print", for: .normal)
        button.titleLabel?.font = Fonts.semiBold(18)
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.layer.cornerRadius = 35
        button.backgroundColor = UIColor(hex: "#4982FF")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#30303D")
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(printButton)
        
        titleLabel.centerXToSuperview()
        titleLabel.topToSuperview(offset: 13, usingSafeArea: true)
        
        closeButton.trailingToSuperview(offset: 16)
        closeButton.centerY(to: titleLabel)
    
        printButton.leadingToSuperview(offset: 16)
        printButton.trailingToSuperview(offset: 16)
        printButton.bottomToSuperview(offset: -20, usingSafeArea: true)
        printButton.height(68)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        printButton.addTarget(self, action: #selector(printTapped), for: .touchUpInside)

    }
    @objc func printTapped() {
        let printFormatter = webView.viewPrintFormatter()
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = "Text Print Job"
        printController.printInfo = printInfo
        
        printController.printFormatter = printFormatter
        printController.present(animated: true) { [weak self] _, success, _ in
            if success {
                self?.navigationController?.dismiss(animated: true)
            }
        }
    }
    @objc func closeTapped() {
        dismiss(animated: true)
    }
    func setupWebView(with url: URL) {
        let webViewConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        let request = URLRequest(url: url)
        webView.load(request)
        webView.layer.cornerRadius = 24
        webView.clipsToBounds = true
        view.insertSubview(webView, at: 1)
        webView.leadingToSuperview(offset: 16)
        webView.trailingToSuperview(offset: 16)
        webView.topToBottom(of: closeButton, offset: 24)
        webView.bottomToTop(of: printButton, offset: -24)
    }
}
