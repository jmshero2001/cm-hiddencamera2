import UIKit
import MessageUI
import StoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, MFMailComposeViewControllerDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        
        if ApplicationCacheService.shared.isOnboardingPassed {
            let homeVC = buildHome(navigationController: navigationController)
            let historyVC = buildHistory(navigationController: navigationController)
            let settingsVC = buildSettings(navigationController: navigationController)
            
            let tabbarController = TabBarSceneViewController(viewControllers: [homeVC, historyVC, settingsVC])
            
            navigationController.viewControllers = [tabbarController]
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        } else {
            let presenter = SubsScenePresenter(isInapp: false)
            let vc = SubsSceneViewController(presenter: presenter)
            presenter.view = vc
            presenter.navigationController = navigationController
                        
            navigationController.viewControllers = [vc]
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        activateQucikAction(shortcutItem)
        return true
    }
    
    func activateQucikAction(_ shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case QucikActions.rate.rawValue:
            openMainAndRAteUsScreen()
        case QucikActions.faq.rawValue:
            openEmailClient()
        case QucikActions.refund.rawValue:
            openEmailClientToCancel()
        case QucikActions.feature.rawValue:
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowGlobalPaywall"),
                object: nil,
                userInfo: nil
            )
        default:
            break
        }
    }
    
    private func openEmailClient() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject("Feedback -" + "6745787696")
            
            window?.rootViewController?.present(mailComposeVC, animated: true, completion: nil)
        }
    }
    
    private func openMainAndRAteUsScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    private func openEmailClientToCancel() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject("Refund - " + "6745787696")
            window?.rootViewController?.present(mailComposeVC, animated: true, completion: nil)
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func buildHome(navigationController: UINavigationController) -> UIViewController {
        let presenter = HomeScenePresenter(navigationController: navigationController)
        let vc = HomeSceneViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }
    private func buildSettings(navigationController: UINavigationController) -> UIViewController {
        let presenter = SettingsScenePresenter(navigationController: navigationController)
        let vc = SettingsSceneViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }
    private func buildHistory(navigationController: UINavigationController) -> UIViewController {
        let presenter = HistoryScenePresenter(navigationController: navigationController)
        let vc = HistorySceneViewController(presenter: presenter)
        return vc
    }
}

final class Fonts {
    static func medium(_ size: CGFloat) -> UIFont {
        UIFont(name: "Outfit-Medium", size: size)!
    }
    static func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "Outfit-Bold", size: size)!
    }
    static func semiBold(_ size: CGFloat) -> UIFont {
        UIFont(name: "Outfit-SemiBold", size: size)!
    }
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: "Outfit-Regular", size: size)!
    }
}
