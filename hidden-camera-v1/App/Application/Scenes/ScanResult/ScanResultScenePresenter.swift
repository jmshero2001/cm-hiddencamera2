import UIKit

final class ScanResultScenePresenter {
    
    weak var view: ScanResultSceneViewController?
    
    private let navigationController: UINavigationController
    
    private let userDefaultsManager = UserDefaultsManager.shared
    
    var wifiDevices: [WiFiDevice]
    var bluetoothDevices: [BluetoothDevice]
    var combinedDevices: [GeneralDevice] = []
    
    init(navigationController: UINavigationController, wifiDevices: [WiFiDevice], bluetoothDevices: [BluetoothDevice]) {
        self.navigationController = navigationController
        self.wifiDevices = wifiDevices
        self.bluetoothDevices = bluetoothDevices
        
        self.combinedDevices = wifiDevices.map { GeneralDevice(fromWiFi: $0) } +
                                       bluetoothDevices.map { GeneralDevice(fromBluetooth: $0) }
        
        saveDevicesToHistory()
    }
    
    private func saveDevicesToHistory() {
        var savedDevices = userDefaultsManager.loadDevices()
        let newDevices = combinedDevices.filter { newDevice in
            !savedDevices.contains(where: { $0.name == newDevice.name })
        }
        savedDevices.append(contentsOf: newDevices)
        userDefaultsManager.saveDevices(savedDevices)
    }
    
    func showPaywall() {
        let presenter = SubsScenePresenter(isInapp: true)
        let vc = SubsSceneViewController(presenter: presenter)
        presenter.navigationController = navigationController
        presenter.view = vc
        vc.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigationController.present(vc, animated: true)
        }
    }
}
