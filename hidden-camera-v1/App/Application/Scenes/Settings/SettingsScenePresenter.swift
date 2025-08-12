import UIKit
import StoreKit
import MessageUI

final class SettingsScenePresenter {
    
    weak var view: SettingsSceneViewController?
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func optionTapped(_ option: SettingsOption) {
        switch option {
        case .feedback:
            showFeedback(subject: "", message: "")
        case .terms:
            openLink(link: "https://docs.google.com/document/d/1kGsllHBj33OAb1FeerX1jbgPCh1DAgZWhMTsUXpQwXw/edit?usp=sharing")
        case .privacy:
            openLink(link: "https://docs.google.com/document/d/1tToq2tma7_sCkExHvlt-Wre_ZXvVmTwi8qwq9_kJI3U/edit?usp=sharing")
        case .rate:
            rate()
        case .share:
            shareWithFriends()
        }
    }
    
    func presentDocumentPicker(delegate: any UIDocumentPickerDelegate) {
        let formats = [
            "com.microsoft.word.doc",
            "com.microsoft.excel.xls",
            "com.adobe.pdf",
            "public.pdf"
        ]
        let documentPicker = UIDocumentPickerViewController(documentTypes: formats, in: .import)
        documentPicker.delegate = delegate
        navigationController.present(documentPicker, animated: true, completion: nil)
    }
    
    private func openLink(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func rate() {
        if let scene = UIApplication
            .shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func shareWithFriends() {
        var activityItems = [Any]()
        
        if let shareURL = URL(string: "https://itunes.apple.com/app/6745787696") {
            activityItems.append(shareURL)
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: activityItems, applicationActivities: nil)
        
        navigationController.present(activityViewController, animated: true)
        
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            activityViewController.dismiss(animated: true)
        }
    }
    
    private func showFeedback(subject: String, message: String) {
        guard MFMailComposeViewController.canSendMail() else { return }
        let viewController = NativeMailComposeViewController()
        viewController.setSubject(subject)
        viewController.setMessageBody(message, isHTML: false)
        navigationController.present(viewController, animated: true)
    }
}

final class NativeMailComposeViewController: MFMailComposeViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        mailComposeDelegate = self
        overrideUserInterfaceStyle = .dark
        modalPresentationStyle = .overFullScreen
        setToRecipients(["horacio3948@icloud.com"])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NativeMailComposeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        dismiss(animated: true)
    }
}
