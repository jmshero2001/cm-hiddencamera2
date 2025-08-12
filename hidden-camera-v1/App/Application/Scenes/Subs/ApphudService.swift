import Foundation
import ApphudSDK
import StoreKit

final class ApphudService {
        
    var hasPremium: Bool {
        Apphud.hasPremiumAccess()
    }
    
    var inAppPaywallHandler: ((PaywallModel) -> Void)?
    var onboardingPaywallHandler: ((PaywallModel) -> Void)?
    
    private(set) var onboardingPaywall: PaywallModel = .init(config: .initial(), products: [])
    private(set) var inAppPaywall: PaywallModel = .init(config: .initial(), products: [])
    
    static let global = ApphudService()
    private init() {
        Task {
            await Apphud.start(apiKey: "app_AD4TVBkoeWrZojqMaLnAgAV8r7gwB7") {
                self.getPaywalls()
            }
        }
    }
    
    func purchase(product: ApphudProduct, completion: (((Bool) -> Void))?) {
        Task {
            await Apphud.purchase(product) { result in
                if let subscription = result.subscription, subscription.isActive() {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        }
    }
    
    func restorePurchase(completion: (((Bool) -> Void))?) {
        Task {
            await Apphud.restorePurchases { _, _, _ in
                completion?(Apphud.hasActiveSubscription())
            }
        }
    }
    
    private func getPaywalls() {
        Task {
            await Apphud.paywallsDidLoadCallback { [weak self] paywalls in
                paywalls.forEach { paywall in
                    self?.configurePaywall(paywall: paywall)
                }
            }
        }
    }
    
    private func configurePaywall(paywall: ApphudPaywall) {
        let identifier = paywall.identifier
        
        let config = parseConfig(with: paywall.json ?? [:])
        
        var products = paywall.products.compactMap { apphudProduct in
            if let skProduct = apphudProduct.skProduct, let unit = skProduct.subscriptionPeriod?.unit {
                
                let price = skProduct.localizedPrice
                let slashPeriod = unit.slashPeriodString()
                let isTrial = apphudProduct.name?.lowercased().contains("trial") ?? false
                
                print("Paywall - \(paywall.identifier), product - \(apphudProduct.name)")
                
                let product = Product(product: apphudProduct, priceAndPeriod: price + slashPeriod, isTrial: isTrial)
                return product
            }
            return nil
        }
        
        
        let paywall_model: PaywallModel = .init(config: config, products: products)
        
        switch identifier {
        case .inAppPaywall:
            inAppPaywall = paywall_model
            inAppPaywallHandler?(paywall_model)
        case .onboardingPaywall:
            onboardingPaywall = paywall_model
            onboardingPaywallHandler?(paywall_model)
        default:
            print("-- Unknown paywall fetched: \(paywall.identifier) ---")
        }
    }
    
    private func parseConfig(with json: [String: Any]) -> PaywallConfig {
        let onboarding_close_delay = json["onboarding_close_delay"] as? Double
        let paywall_close_delay = json["paywall_close_delay"] as? Double
        let onboarding_button_title = json["onboarding_button_title"] as? String
        let paywall_button_title = json["paywall_button_title"] as? String
        let onboarding_subtitle_alpha = json["onboarding_subtitle_alpha"] as? Double
        let is_paging_enabled = json["is_paging_enabled"] as? Bool ?? true
        let is_review_enabled = json["is_review_enabled"] as? Bool ?? true
        
        return .init(onboarding_close_delay: onboarding_close_delay,
                     paywall_close_delay: paywall_close_delay,
                     onboarding_button_title: onboarding_button_title,
                     paywall_button_title: paywall_button_title,
                     onboarding_subtitle_alpha: onboarding_subtitle_alpha,
                     is_paging_enabled: is_paging_enabled,
                     is_review_enabled: is_review_enabled)
    }
}

extension String {
    static let empty = ""
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = priceLocale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let decimalPrice = formatter.string(from: price) ?? .empty
        let currencySymbol = priceLocale.currencySymbol ?? "$"
        return currencySymbol + decimalPrice
    }
}

extension SKProduct.PeriodUnit {
    func perPeriodString() -> String {
        if self == .day {
            return "per week"
        } else if self == .month {
            return "per month"
        } else if self == .year {
            return "per year"
        }
        return "per --//--"
    }
    
    func slashPeriodString() -> String {
        if self == .day {
            return "/week"
        } else if self == .month {
            return "/month"
        } else if self == .year {
            return "/year"
        }
        return "/--//--"
    }
}

extension String {
    static let inAppPaywall = "inapp_paywall"
    static let onboardingPaywall = "onboarding_paywall"
}
import Foundation
import Combine
import UIKit
import Network
import NetworkExtension

final class WiFiManager: NSObject, NetServiceDelegate {
    
    static let shared = WiFiManager()
    
    var noConnectionClosure: ((ConnectionDenideType) -> Void)?
    var endScanningClosure: (() -> Void)?
    
    @Published private(set) var devices = [WiFiDevice]()
    @Published private var wiFiData: WiFiData?
    
    @Published private(set) var wifiAvailable = false
    @Published private(set) var localAvailable = false
    @Published private(set) var isScanning = false
    
    private var browser: NWBrowser?
    private var netService: NetService?
    private let serviceDiscoverer = DiscovererManager()
    
    private let pathMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
    private let globalQueue = DispatchQueue.global(qos: .userInteractive)
    
    private var subscriptions = Set<AnyCancellable>()
    
    override init() {
        super.init()
        observeServices()
        requestAuthorization()
    }
    
    func start() {
        if !localAvailable {
            noConnectionClosure?(.local)
            requestAuthorization()
        } else if !wifiAvailable {
            noConnectionClosure?(.wifi)
        } else if localAvailable, wifiAvailable {
            serviceDiscoverer.start()
            isScanning = true
        }
    }
    
    func stop() {
        guard isScanning else { return }
        serviceDiscoverer.stop()
        isScanning = false
    }
    
    func requestAuthorization() {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        let browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: parameters)
        self.browser = browser
        
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .waiting(_):
                self.localAvailable = false
                self.resetService()
            default:
                break
            }
        }
        
        self.netService = NetService(domain: "local.", type:"_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        self.netService?.delegate = self
        
        self.browser?.start(queue: .main)
        self.netService?.publish()
    }
    
    private func observeServices() {
        serviceDiscoverer.$foundDevices.assign(to: &$devices)
        serviceDiscoverer.scanningFinished = { [weak self] in
            self?.isScanning = false
            self?.endScanningClosure?()
        }
        
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch path.status {
                case .satisfied:
                    self.updateWifiData()
                    self.wifiAvailable = true
                case .requiresConnection, .unsatisfied:
                    self.wifiAvailable = false
                @unknown default:
                    self.wifiAvailable = false
                }
            }
        }
        
        pathMonitor.start(queue: globalQueue)
    }
    
    private func updateWifiData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NEHotspotNetwork.fetchCurrent { [weak self] network in
                guard let self, let network else { return }
                
                let ssid = network.ssid
                let adress = self.takeWFAddress()
                
                self.wiFiData = .init(name: ssid, ip: adress)
            }
        }
    }
    
    private func takeWFAddress() -> String? {
        var address : String?
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
        sequence(first: firstAddr, next: { $0.pointee.ifa_next }).forEach { ifptr in
            
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                
                if  name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    private func resetService() {
           self.browser?.cancel()
           self.browser = nil
           self.netService?.stop()
           self.netService = nil
       }
    
    func netServiceDidPublish(_ sender: NetService) {
        self.resetService()
        self.localAvailable = true
    }
}



import Foundation

final class ServicesDiscoverer: NSObject, NetServiceDelegate, NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        generalServicesDiscoverer.deleteDiscoverer(discoverer: self)
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        generalServicesDiscoverer.deleteDiscoverer(discoverer: self)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.insert(service)
        service.delegate = self
        service.resolve(withTimeout: 1)
    }
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let addresses = sender.addresses else { return }
        
        var deviceAddress = "-"
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        
        for data in addresses {
            do {
                try data.withUnsafeBytes { (pointer: UnsafePointer<sockaddr>) -> Void in
                    guard getnameinfo(pointer, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        throw NSError(domain: "domain", code: 0, userInfo: ["error": "failed get ip address"])
                    }
                }
            } catch {
                debugPrint(error)
            }
            
            let address = String(cString:hostname)
            if address.components(separatedBy: ".").count == 4 {
                deviceAddress = address
                break
            }
        }
        
        if !generalServicesDiscoverer.devices.contains(where: { $0.ip == deviceAddress }) && deviceAddress != "-" {
            let device = WiFiDevice.init(services: [service.name], ip: deviceAddress,
                                         hostName: sender.hostName?.components(separatedBy: ".").first ?? "-")
            generalServicesDiscoverer.devices.insert(device)
        } else {
            guard let item = generalServicesDiscoverer.devices.first(where: { $0.ip == deviceAddress }) else { return }
            item.services.append(service.name)
        }
    }
    private let browser = NetServiceBrowser()
    private var services = Set<NetService>()
    private let service: NetService
    
    private let generalServicesDiscoverer: DiscovererManager
    
    init(service: NetService, generalServicesDiscoverer: DiscovererManager) {
        self.service = service
        self.generalServicesDiscoverer = generalServicesDiscoverer
        super.init()
        browser.delegate = self
    }
    
    func start() {
        let parts = service.type.components(separatedBy: ".")
        let type = "\(service.name).\(parts[0])."
        browser.searchForServices(ofType: type, inDomain: "local.")
    }
    
    func stop() { browser.stop()}

}


import Foundation

final class DiscovererManager: NSObject, NetServiceBrowserDelegate {
    
    var scanningFinished: (() -> Void)?
    
    private let browser = NetServiceBrowser()
    private var timer: Timer?
    
    @Published private(set) var foundDevices = [WiFiDevice]()
    
    private var serviceDiscoverers = Set<ServicesDiscoverer>()
    var devices = Set<WiFiDevice>()
    
    @objc func stop() {
        timer?.invalidate()
        browser.stop()
        serviceDiscoverers.forEach { $0.stop() }
        foundDevices = Array(devices)
        scanningFinished?()
    }
    
    func start() {
        devices.removeAll()
        serviceDiscoverers.removeAll()
        browser.stop()
        browser.delegate = self
        browser.includesPeerToPeer = true
        browser.searchForServices(ofType: "_services._dns-sd._udp.", inDomain: "local.")
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stop), userInfo: nil, repeats: false)
    }
    
    func deleteDiscoverer(discoverer: ServicesDiscoverer) {
        serviceDiscoverers.remove(discoverer)
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        let serviceDiscoverer = ServicesDiscoverer(service: service, generalServicesDiscoverer: self)
        serviceDiscoverers.insert(serviceDiscoverer)
        serviceDiscoverer.start()
    }
}


import Foundation

final class ApplicationCacheService {
    static let shared = ApplicationCacheService()
    private init() {}
    
    private let onboardingKey = "isOnboardingPassed"
    private let isFreeContentPassedKey = "isFreeContentPassed"
    
    var isOnboardingPassed: Bool {
        UserDefaults.standard.bool(forKey: onboardingKey)
    }
        
    func setOnboardingPassed() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    var isFreeContentPassed: Bool {
        UserDefaults.standard.bool(forKey: isFreeContentPassedKey)
    }
        
    func setFreeContentPassed() {
        UserDefaults.standard.set(true, forKey: isFreeContentPassedKey)
    }
}
import Foundation
import CoreBluetooth
import Combine

final class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startScanBluetoothConnections()
        default:
            isScanning = false
            debugPrint("doesn't supported")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name,
              !devices.value.contains(where: { $0.id == peripheral.identifier }) else {
            return
        }
        peripheral.delegate = self
        
        let device = BluetoothDevice.init(id: peripheral.identifier,
                                          name: deviceName,
                                          distance: "\(rssiConvertToMeters(rssi: RSSI))",
                                          searchedDate: Date(),
                                          peripheral: peripheral)
        
        devices.value.append(device)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(detectionDistance), userInfo: nil, repeats: true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isScanning = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        timer?.invalidate()
        guard error == nil else { return }
        central.connect(peripheral)
    }
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        distance = CGFloat(rssiConvertToMeters(rssi: RSSI))
    }
    static let shared = BluetoothManager()
    
    var lastScanDetectionDateUpdated: (() -> Void)?
    var unauthorizedBluetooth: (() -> Void)?
    var poweredOffBluetooth: (() -> Void)?
    
    private lazy var btManager: CBCentralManager = .init(delegate: self, queue: nil)
    private(set) var devices = CurrentValueSubject<[BluetoothDevice], Never>([])
    
    @Published private(set) var distance: CGFloat = 0
    @Published private(set) var isScanning = false
    
    private var timer: Timer?
    
    private var observableDevice: BluetoothDevice? {
        didSet {
            guard let devicePeripheral = observableDevice?.peripheral else {
                timer?.invalidate()
                return
            }
            btManager.connect(devicePeripheral)
        }
        willSet {
            guard let peripheral = observableDevice?.peripheral else { return }
            btManager.cancelPeripheralConnection(peripheral)
            
        }
    }
    
    func setObservableDevice(id: UUID) {
        guard let device = devices.value.first(where: { $0.id == id }) else {
            debugPrint("device doesn't exist")
            return
        }
        observableDevice = device
    }
    
    func stopScan() {
        guard isScanning else { return }
        btManager.stopScan()
        timer?.invalidate()
        observableDevice = nil
        isScanning = false
    }
    
    private func rssiConvertToMeters(rssi: NSNumber) -> Double {
        round(pow(10, ((-69 - Double(truncating: rssi)) / 20)) * 10) / 10
    }
    
    func startScanBluetoothConnections() {
        switch btManager.state {
        case .unauthorized:
            unauthorizedBluetooth?()
        case .poweredOff:
            poweredOffBluetooth?()
        case .poweredOn:
            devices.value.removeAll()
            btManager.scanForPeripherals(withServices: nil)
            isScanning = true
        default:
            return
        }
    }
    
    @objc private func detectionDistance() {
        guard let observableDevice else { return }
        observableDevice.peripheral?.readRSSI()
    }
}

