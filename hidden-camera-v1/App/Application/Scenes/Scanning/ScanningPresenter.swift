import UIKit
import Combine

enum TypeOfScanning {
    case bluetooth
    case wifi
}

final class ScanningPresenter {
    var showScanning: (() -> ())?
    weak var view: ScanningSceneViewController?
    
    private let navigationController: UINavigationController
    
    private let wiFiManager = WiFiManager.shared
    private let bluetoothManager = BluetoothManager.shared
    
    private var scanTimer: Timer?
    
    var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController, typeOfScanning: TypeOfScanning) {
        self.navigationController = navigationController
        
        startScanning(typeOfScanning: typeOfScanning)
    }
    
    func startScanning(typeOfScanning: TypeOfScanning) {
        switch typeOfScanning {
        case .bluetooth:
            startScanBluetooth()
        case .wifi:
            startScanWifi()
        }
    }
    
    func startScanWifi() {
        wiFiManager.start()
        
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.handleScanWifiResult()
        }
    }
    
    func stopScanWifi() {
        wiFiManager.stop()
        scanTimer?.invalidate()
    }
    
    func handleScanWifiResult() {
        stopScanWifi()
        let devices = wiFiManager.devices

        if devices.isEmpty {
            navigationController.dismiss(animated: true) {
                let vc = DeviceNotFoundViewController()
                vc.showScanning = self.showScanning
                vc.modalPresentationStyle = .overCurrentContext
                self.navigationController.present(vc, animated: true)
            }
        } else {
            navigationController.dismiss(animated: true) {
                self.showScanResult(wifiDevices: devices, bluetoothDevices: [])
            }
      
        }
    }
    
    func showScanResult(wifiDevices: [WiFiDevice], bluetoothDevices: [BluetoothDevice]) {
        let presenter = ScanResultScenePresenter(navigationController: navigationController, wifiDevices: wifiDevices, bluetoothDevices: bluetoothDevices)
        let vc = ScanResultSceneViewController(presenter: presenter)
        vc.showScanning = showScanning
        vc.modalPresentationStyle = .overCurrentContext
        presenter.view = vc
        navigationController.present(vc, animated: true)
    }
}

extension ScanningPresenter {
    func startScanBluetooth() {
        bluetoothManager.startScanBluetoothConnections()
        
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.handleScanBluetoothResult()
        }
    }
    
    func stopScanBluetooth() {
        bluetoothManager.stopScan()
        scanTimer?.invalidate()
    }
    
    func handleScanBluetoothResult() {
        stopScanBluetooth()
        let devices = bluetoothManager.devices.value
        
        if devices.isEmpty {
            navigationController.dismiss(animated: true) {
                let vc = DeviceNotFoundViewController()
                vc.showScanning = self.showScanning
                vc.modalPresentationStyle = .overCurrentContext
                self.navigationController.present(vc, animated: true)
            }
        } else {
            navigationController.dismiss(animated: true) {
                self.showScanResult(wifiDevices: [], bluetoothDevices: devices)
            }
        }
    }
}
