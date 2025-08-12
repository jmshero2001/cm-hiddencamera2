import UIKit
import TinyConstraints
import AdvancedPageControl
import Combine
import ApphudSDK

final class SubsSceneViewController: UIViewController {
    
    let restoreButton = UIButton()
    let trialSwitcher = TrialSwitcher()

    private let privacyAndTermsView = PrivacyAndTermsView()
    private var cancellables: Set<AnyCancellable> = []
    private var presenter: SubsScenePresenter
    
    private lazy var bgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = presenter.isInapp ?UIImage(named: "paywall")  : UIImage(named: "ob1")
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = Fonts.bold(28)
        label.text = ObStep.first.title
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.5)
        label.font = Fonts.medium(16)
        label.text = ObStep.first.subtitle
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var pageControl: AdvancedPageControlView = {
        let pageControl = AdvancedPageControlView()
        pageControl.drawer = ExtendedDotDrawer(height: 6,
                                               width: 6,
                                               space: 8,
                                               raduis: 3,
                                               indicatorColor: UIColor(hex: "#2370E5"),
                                               dotsColor: UIColor(named: "dot"), borderColor: .clear)
        
        
        pageControl.numberOfPages = 5
        pageControl.alpha = 0
        pageControl.height(6)
        return pageControl
    }()
    private let proceedButton = AppButton(title: "Start")
    
    private lazy var titlesStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.height(126)
        return stack
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titlesStackView, pageControl, proceedButton, privacyAndTermsView])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let containerView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "container")
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cross"), for: .normal)
        button.alpha = 0.0
        return button
    }()
    
    init(presenter: SubsScenePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        configureViewLayout()
        connect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presenter.isInapp {
            presenter.onViewDidAppear()
        }
    }
    
    private func addSubviews() {
        view.addSubview(bgView)
        view.addSubview(containerView)
        view.addSubview(stackView)
        view.addSubview(closeButton)
        view.addSubview(restoreButton)
    }
    
    private func configureViewLayout() {
        bgView.edgesToSuperview()
        
        proceedButton.width(UIScreen.main.bounds.width - 40)
        
        stackView.centerXToSuperview()
        stackView.bottomToSuperview(usingSafeArea: true)
        
        containerView.edgesToSuperview(excluding: .top)
        containerView.top(to: stackView, offset: -24)
        
        closeButton.trailingToSuperview(offset: 16)
        closeButton.topToSuperview(offset: 16, usingSafeArea: true)

        
        proceedButton.height(64)
        
        restoreButton.alpha = 0.0
        restoreButton.setTitle("Restore", for: .normal)
        restoreButton.titleLabel?.font = Fonts.medium(12)
        restoreButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        
  
        trialSwitcher.width(UIScreen.main.bounds.width - 40)
        
        restoreButton.centerY(to: closeButton)
        restoreButton.leadingToSuperview(offset: 16)
        
        privacyAndTermsView.height(38)
        
        trialSwitcher.completion = { isOn in
            
            if self.presenter.isInapp {
                let product = self.presenter.inappPaywall.products.first(where: {$0.isTrial != true})
                let trialProduct = self.presenter.inappPaywall.products.first(where: {$0.isTrial == true})
                
                print("Product - \(product)")
                print("Trial Product - \(trialProduct)")
                print("Products - \(self.presenter.inappPaywall.products)")
                
                if isOn {
                    self.presenter.currentProduct = trialProduct
                    self.subtitleLabel.text = self.configureSubtitle(for: trialProduct)
                    
                    if let paywall_button_title = self.presenter.inappPaywall.config.paywall_button_title {
                        self.proceedButton.setTitle(paywall_button_title)
                    } else {
                        self.proceedButton.setAutoRenewable(product: trialProduct)
                    }
                } else {
                    self.presenter.currentProduct = product
                    self.subtitleLabel.text = self.configureSubtitle(for: product)
                    if let paywall_button_title = self.presenter.inappPaywall.config.paywall_button_title {
                        self.proceedButton.setTitle(paywall_button_title)
                    } else {
                        self.proceedButton.setAutoRenewable(product: product)
                    }
                }
            }
          
        }
    
    }
    
    private func connect() {
        proceedButton.addTarget(self, action: #selector(proceedTapped), for: .touchUpInside)
        privacyAndTermsView.termsTapHandler = {
            self.presenter.openLink(link: "https://docs.google.com/document/d/1kGsllHBj33OAb1FeerX1jbgPCh1DAgZWhMTsUXpQwXw/edit?usp=sharing")
        }
        privacyAndTermsView.privacyTapHandler = {
            self.presenter.openLink(link: "https://docs.google.com/document/d/1tToq2tma7_sCkExHvlt-Wre_ZXvVmTwi8qwq9_kJI3U/edit?usp=sharing")
        }
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
    }
    
    @objc func closeTapped() {
        self.presenter.dismiss()
    }
    
    @objc func proceedTapped() {
        self.presenter.proceedTapped()
    }
    

    
    @objc func restoreTapped() {
        self.presenter.restore()
    }
    
    private func configureSubtitle(for product: Product?) -> String {
        var base: String
        base = product?.isTrial ?? false
        ? "Start to continue Device Finder\nwith 3-days free trial and "
        : "Start to continue Device Finder\nwith no limits just for "
        
        let subtitle = base + (product?.priceAndPeriod ?? "-//-")
        return subtitle
    }
    
    private func configureProceedTitle(for product: Product?) -> String {
        var base: String
        base = product?.isTrial ?? false
        ? "Try trial then "
        : "Continue for "
        
        let subtitle = base + (product?.priceAndPeriod ?? "-//-")
        return subtitle
    }
}

extension SubsSceneViewController {
    func displayScene(for step: ObStep, config: PaywallConfig) {
        pageControl.alpha = config.is_paging_enabled ? 1.0 : 0.0
        subtitleLabel.alpha = config.onboarding_subtitle_alpha ?? 1.0
        bgView.setImageAnimated(step.image)
        titleLabel.text = step.title
        subtitleLabel.text = step.subtitle
        pageControl.setPage(step.rawValue)
        proceedButton.setTitle(step == .first ? "Start" : "Continue")
    }
    
    func displayPaywall(config: PaywallConfig, product: Product?) {
        privacyAndTermsView.fadeIn()
        pageControl.setPage(3)
        bgView.setImageAnimated(UIImage(named: "paywall") )
        
        var base: String
        base = product?.isTrial ?? false
        ? "Get unlimited access to Device Finder"
        : "Get unlimited access to Device Finder"
        
        titleLabel.text = base
        subtitleLabel.text = configureSubtitle(for: product)
        proceedButton.setTitle(config.onboarding_button_title ?? configureProceedTitle(for: product))
        restoreButton.fadeIn(delay: 1.0)
        closeButton.fadeIn(delay: config.onboarding_close_delay ?? 0.0)
        restoreButton.isHidden = false
        
        if let paywall_button_title = self.presenter.inappPaywall.config.paywall_button_title {
            self.proceedButton.setTitle(paywall_button_title)
        } else {
            self.proceedButton.setAutoRenewable(product: product)
        }
    }
    
    func displayInappPaywall(config: PaywallConfig, product: Product?, toShowSwitcher: Bool) {
        privacyAndTermsView.fadeIn()
        bgView.setImageAnimated(UIImage(named: "paywall") )
        titleLabel.text = "Full access\nto all features"
        subtitleLabel.text = configureSubtitle(for: product)
        proceedButton.setTitle(config.paywall_button_title ?? configureProceedTitle(for: product))
        restoreButton.fadeIn(delay: 1.0)
        
        if toShowSwitcher {
            stackView.insertArrangedSubview(trialSwitcher, at: 2)
           
        }
        
        if let paywall_button_title = self.presenter.inappPaywall.config.paywall_button_title {
            self.proceedButton.setTitle(paywall_button_title)
        } else {
            self.proceedButton.setAutoRenewable(product: product)
        }
        
        stackView.removeArrangedSubview(pageControl)
        pageControl.removeFromSuperview()
    }
    func onViewDidAppear(config: PaywallConfig) {
        closeButton.fadeIn(delay: config.paywall_close_delay ?? 0.0)
    }
}

// MARK: - MODELS

struct Product {
    let product: ApphudProduct
    let priceAndPeriod: String
    let isTrial: Bool
}

struct PaywallModel {
    let config: PaywallConfig
    let products: [Product]
}

struct PaywallConfig {
    
    let onboarding_close_delay: Double?
    let paywall_close_delay: Double?
    let onboarding_button_title: String?
    let paywall_button_title: String?
    let onboarding_subtitle_alpha: Double?
    let is_paging_enabled: Bool
    let is_review_enabled: Bool
    
    static func initial() -> PaywallConfig {
        .init(onboarding_close_delay: nil,
              paywall_close_delay: nil,
              onboarding_button_title: nil,
              paywall_button_title: nil,
              onboarding_subtitle_alpha: nil,
              is_paging_enabled: true,
              is_review_enabled: true)
    }
}
extension UIImageView {
    func setImageAnimated(_ image: UIImage?) {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}

extension UIView {
    func roundCorners(radius: CGFloat, corners: CACornerMask) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}

extension UIView {
    func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: (() -> Void)? = nil) {
        self.alpha = 0.0
        self.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 1.0
            }, completion: { _ in
                completion?()
            })
        }
    }
}


import UIKit
import StoreKit

final class SubsScenePresenter {
    
    var currentProduct: Product?
    
    let isInapp: Bool
    
    private var purchaseCompletion: (((Bool) -> Void))?
    private var restoreCompletion: (((Bool) -> Void))?

    private var currentStep: ObStep = .first
    
    weak var view: SubsSceneViewController? {
        didSet {
            if isInapp {
                if let product = inappPaywall.products.first(where: {$0.isTrial == false}) {
                    self.currentProduct = product
                    view?.displayInappPaywall(config: paywall.config, product: product, toShowSwitcher: inappPaywall.products.contains(where: {$0.isTrial == true}))
                }
            }
        }
    }
    weak var navigationController: UINavigationController?
    
    private var apphudService = ApphudService.global
    
    var paywall: PaywallModel {
        apphudService.onboardingPaywall
    }
    var inappPaywall: PaywallModel {
        apphudService.inAppPaywall
    }
    
    init(isInapp: Bool) {
        self.isInapp = isInapp
        addActions()
    }
    
    private func addActions() {
        if isInapp {
            apphudService.inAppPaywallHandler = { [weak self] paywall in
                guard let self else { return }
                if let product = paywall.products.first(where: {$0.isTrial == false}) {
                    self.currentProduct = product
                    view?.displayInappPaywall(config: paywall.config, product: product, toShowSwitcher: paywall.products.contains(where: {$0.isTrial == true}))
                }
            }
        } else {
            apphudService.onboardingPaywallHandler = { [weak self] paywall in
                guard let self else { return }
                if currentStep != .paywall {
                    if let product = paywall.products.first {
                        self.currentProduct = product
                    }
                    view?.displayScene(for: currentStep, config: paywall.config)
                } else {
                    if let product = paywall.products.first {
                        self.currentProduct = product
                        view?.displayPaywall(config: paywall.config, product: product)
                    }
                }
            }
        }
     
        restoreCompletion = { [weak self] success in
            if success {
                self?.dismiss()
            }
        }
        purchaseCompletion = { [weak self] success in
            if success {
                self?.dismiss()
            }
        }
    }
    
    private func handleReviewAlert() {
        guard currentStep == .second,
              paywall.config.is_review_enabled,
              let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}

extension SubsScenePresenter {
    func onViewDidLoad() {
        view?.displayScene(for: currentStep, config: paywall.config)
    }
    func proceedTapped() {
        if isInapp {
            purchase()
        } else {
            if currentStep == .third {
                view?.displayPaywall(config: paywall.config, product: paywall.products.first)
            }
            
            if currentStep == .paywall {
                purchase()
                return
            }
            currentStep.next()
            if currentStep != .paywall {
                handleReviewAlert()
                view?.displayScene(for: currentStep, config: paywall.config)
            }
        }
    }
    func onViewDidAppear() {
        view?.onViewDidAppear(config: isInapp ? inappPaywall.config :  paywall.config)
    }
    func purchase() {
        guard let product = currentProduct else { return }
        apphudService.purchase(product: product.product, completion: purchaseCompletion)
    }
    
    func restore() {
        apphudService.restorePurchase(completion: restoreCompletion)
    }
    
    func dismiss() {
        if isInapp {
            navigationController?.dismiss(animated: true)
        } else {
            showMain()
        }
    }

    private func showMain() {
        guard let navigationController else { return }
        ApplicationCacheService.shared.setOnboardingPassed()
        let homeVC = buildHome(navigationController: navigationController)
        let historyVC = buildHistory(navigationController: navigationController)
        let settingsVC = buildSettings(navigationController: navigationController)
        let tabbarController = TabBarSceneViewController(viewControllers: [homeVC, historyVC, settingsVC])
        navigationController.viewControllers = [tabbarController]
    }
    
    func openLink(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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

enum ApphudErrors {
    case purchase
    case restore
    
    var message: String {
        switch self {
        case .purchase:
            "Purchase error occured"
        case .restore:
            "Restore error occured"
        }
    }
}

final class TrialSwitcher: UIView {
    
    var completion: ((Bool) -> ())?
    
    // MARK: UI
    
    let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor(hex: "#4982FF")
        return switcher
    }()
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        
        height(48)
        backgroundColor = UIColor(hex: "#2F2F37")
        layer.cornerRadius = 18
        addActions()
        
        addSubview(switcher)
        switcher.centerYToSuperview()
        switcher.trailingToSuperview(offset: 15)
        
        let title = UILabel()
        title.text = "Enable a 3-day trial"
        title.textColor = UIColor(hex: "#FFFFFF")
        title.font = Fonts.medium(16)
        addSubview(title)
        title.centerYToSuperview()
        title.leadingToSuperview(offset: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers

    private func addActions() {
        switcher.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        completion?(sender.isOn)
    }
    
    // MARK: External
    
    func setSwitcherState(isOn: Bool) {
        switcher.isOn = isOn
    }

    func setSwitcherStateInapp(isOn: Bool) {
        switcher.isOn = isOn
        completion?(isOn)
    }
}

final class PrivacyAndTermsView: UIView {
    
    var termsTapHandler: (() -> ())?
    var privacyTapHandler: (() -> ())?
    
    private let byContinueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.5)
        label.font = Fonts.regular(12)
        label.text = "by continue you agree to"
        return label
    }()
    private let andLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.3)
        label.font = Fonts.regular(12)
        label.text = "and"
        return label
    }()
    private let termsButton: Button = {
        let button = Button()
        button.setTitle("Terms of Service", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF").withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = Fonts.regular(12)
        return button
    }()
    private let privacyButton: Button = {
        let button = Button()
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF").withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = Fonts.regular(12)
        return button
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [termsButton, andLabel, privacyButton])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .equalSpacing
        return stack
    }()
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [byContinueLabel, hStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 1
        return stack
    }()
    init() {
        super.init(frame: .zero)
        alpha = 0.0
        addSubviews()
        setupConstraints()
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(vStack)
    }
    
    private func setupConstraints() {
        vStack.edgesToSuperview()
    }
    
    private func addActions() {
        termsButton.tapHandler = { [weak self] in
            self?.termsTapHandler?()
        }
        privacyButton.tapHandler = { [weak self] in
            self?.privacyTapHandler?()
        }
    }
}
import Foundation

final class UserDefaultsManager {
    private let devicesKey = "foundDevices"
    
    static let shared = UserDefaultsManager()
    
    func saveDevices(_ devices: [GeneralDevice]) {
        if let data = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(data, forKey: devicesKey)
        }
    }
    
    func loadDevices() -> [GeneralDevice] {
        guard let data = UserDefaults.standard.data(forKey: devicesKey),
              let devices = try? JSONDecoder().decode([GeneralDevice].self, from: data) else {
            return []
        }
        return devices
    }
}
