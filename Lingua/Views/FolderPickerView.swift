import SwiftUI
#if os(iOS)

typealias FolderResultHandler = (Result<URL, Error>?) -> Void

struct FolderPickerView: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let resultHandler: FolderResultHandler
        
        init(resultHandler: @escaping FolderResultHandler) {
            self.resultHandler = resultHandler
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                resultHandler(.failure(CocoaError(.fileReadUnknown)))
                return
            }
            
            resultHandler(.success(url))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            resultHandler(nil)
        }
    }
    
    let resultHandler: FolderResultHandler
    
    init(resultHandler: @escaping FolderResultHandler) {
        self.resultHandler = resultHandler
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(resultHandler: resultHandler)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
}
#endif
