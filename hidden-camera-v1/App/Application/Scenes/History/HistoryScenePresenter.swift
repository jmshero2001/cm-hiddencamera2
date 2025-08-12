import UIKit
import Combine

final class HistoryScenePresenter {
    
    weak var view: HistorySceneViewController?
    
    private let navigationController: UINavigationController
    
    private let userDefaultsManager = UserDefaultsManager.shared
    
    let savedDevicesSubject = CurrentValueSubject<[GeneralDevice], Never>([])
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        loadDevices()
    }
    
    func loadDevices() {
        let devices = userDefaultsManager.loadDevices()
        
//        let devices: [GeneralDevice] = [
//            .init(fromWiFi: .init(services: ["23"], ip: "23423", hostName: "MAC BOOK PRO 16 M1 PRO")),
//            .init(fromWiFi: .init(services: ["23"], ip: "23423", hostName: "NEW")),
//            .init(fromWiFi: .init(services: ["23"], ip: "23423", hostName: "NEW")),
//        ]
        savedDevicesSubject.send(devices)
        print("Loaded devices: \(devices)")
    }
    
    func presentDocumentPicker(delegate: any UIDocumentPickerDelegate) {
        let formats = [
            "com.microsoft.word.doc",
            "org.openxmlformats.wordprocessingml.document",
            "public.jpeg",
            "public.png",
            "public.heic",
            "com.microsoft.excel.xls",
            "com.adobe.pdf",
            "public.pdf"
        ]
        let documentPicker = UIDocumentPickerViewController(documentTypes: formats, in: .import)
        documentPicker.delegate = delegate
        navigationController.present(documentPicker, animated: true, completion: nil)
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
