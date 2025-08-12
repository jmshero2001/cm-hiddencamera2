import UIKit

final class TabButton: UIButton {
    
    enum Tabs: String {
        
        case scanner
        case history
        case settings

        var title: String {
            switch self {
            case .scanner:
                "Finder"
            case .history:
                "History"
            case .settings:
                "Settings"
            }
        }
        
        var image: UIImage? {
            UIImage(named: rawValue)
        }
        
        var selectedImage: UIImage? {
            UIImage(named: rawValue + "Selected")
        }
    }
    
    private let tab: Tabs
    
    private lazy var image: UIImageView = {
        let iv = UIImageView()
        iv.alpha = 0.5
        return iv
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#59636E")
        label.text = tab.title
        label.font = Fonts.semiBold(12)
        return label
    }()
    
    init(tab: Tabs) {
        self.tab = tab
        super.init(frame: .zero)
        setupStyle()
        arrangeSubviews()
        setupViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStyle() {
        layer.cornerRadius = 14
    }
    
    func arrangeSubviews() {
        addSubview(image)
        addSubview(label)
    }
    
    func setupViewConstraints() {
        image.topToSuperview(offset: 15)
        image.height(24)
        image.width(24)
        image.centerXToSuperview()
        
        label.centerXToSuperview()
        label.topToBottom(of: image, offset: 4)
    }
    
    func select(toSelect: Bool) {
        image.image = toSelect ? tab.selectedImage : tab.image
        label.textColor = toSelect ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#59636E")
        image.alpha = toSelect ? 1.0 : 0.5
    }
}


final class AppTabBarView: UIView {
    
    private lazy var tabs = [scannerTab, historyTab, settingsTab]
    
    private let scannerTab: TabButton = .init(tab: .scanner)
    private let historyTab: TabButton = .init(tab: .history)
    private let settingsTab: TabButton = .init(tab: .settings)
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: tabs)
        stack.axis = .horizontal
        stack.spacing = 25
        stack.distribution = .fillEqually
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        
//        backgroundColor = Colors.tabBarBg
        addSubview(stackView)
        stackView.topToSuperview()
        stackView.bottomToSuperview()
        stackView.leadingToSuperview(offset: 16)
        stackView.trailingToSuperview(offset: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectedTab(index: Int) {
        tabs.forEach({ $0.select(toSelect: false) })
        tabs[index].select(toSelect: true)
    }
}

final class AppTabBar: UITabBar {
    
    private let appTabBarView = AppTabBarView()
    
    init() {
        super.init(frame: .zero)
        addSubviews()
        setupViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        let screenHeight = UIScreen.main.bounds.height
        newSize.height = screenHeight / 9
        return newSize
    }
    
    // MARK: Helpers
    
    private func addSubviews() {
        addSubview(appTabBarView)
    }
    
    private func setupViewConstraints() {
        appTabBarView.edgesToSuperview()
    }
    
    func setSelectedTab(index: Int) {
        appTabBarView.setSelectedTab(index: index)
    }
}

final class TabBarSceneViewController: UITabBarController {
    
    // MARK: UI
    
    private let appTabBar = AppTabBar()
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        
        setValue(appTabBar, forKey: "tabBar")
        delegate = self
        
        view.backgroundColor = .clear
        self.viewControllers = viewControllers
        appTabBar.setSelectedTab(index: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension TabBarSceneViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        appTabBar.setSelectedTab(index: selectedIndex)
    }
}
