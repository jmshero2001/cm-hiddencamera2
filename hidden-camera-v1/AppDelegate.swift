import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureQuickActions(for: application)

        return true
    }

    func configureQuickActions(for application: UIApplication) {
        application.shortcutItems = QucikActions.allCases.reversed().map({$0.quickActionItem})
    }

}

enum QucikActions: String, CaseIterable {

    case rate
    case faq
    case refund
    case feature

    var quickActionItem: UIApplicationShortcutItem {
        switch self {
        case .rate:
            return UIApplicationShortcutItem(
                type: rawValue,
                localizedTitle: "Enjoying the app?\nRate us now! 🔍",
                localizedSubtitle: "Your support helps us improve",
                icon: UIApplicationShortcutIcon(systemImageName: "hand.thumbsup.fill")
            )
        case .faq:
            return UIApplicationShortcutItem(
                type: rawValue,
                localizedTitle: "Need help?\nWe’ve got answers 🛡",
                localizedSubtitle: "Find tips and troubleshooting",
                icon: UIApplicationShortcutIcon(systemImageName: "message.fill")
            )
        case .refund:
            return UIApplicationShortcutItem(
                type: rawValue,
                localizedTitle: "Request a refund? 💳",
                localizedSubtitle: "Manage your subscription easily",
                icon: UIApplicationShortcutIcon(systemImageName: "xmark.circle.fill")
            )
        case .feature:
            return UIApplicationShortcutItem(
                type: rawValue,
                localizedTitle: "Start Camera Scan 🎯",
                localizedSubtitle: "Quickly scan for devices",
                icon: UIApplicationShortcutIcon(systemImageName: "video.circle.fill")
            )
        }
    }
}


