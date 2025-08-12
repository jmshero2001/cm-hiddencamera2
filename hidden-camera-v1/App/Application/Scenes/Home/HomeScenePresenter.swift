import UIKit
import Combine

final class HomeScenePresenter {
    
    weak var view: HomeSceneViewController?
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
