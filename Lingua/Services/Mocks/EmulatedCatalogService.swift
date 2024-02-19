import Foundation
import Combine
import TranslationCatalog
import TranslationCatalogFilesystem
import LocaleSupport

class EmulatedCatalogService: CatalogService {
    
    var _localeIdentifiers: Set<Locale.Identifier>
    
    var catalog: Catalog? { catalogSubject.value }
    var contentMode: ContentMode? { contentModeSubject.value }
    
    var catalogPublisher: AnyPublisher<Catalog?, Never> { catalogSubject.eraseToAnyPublisher() }
    var contentModePublisher: AnyPublisher<ContentMode?, Never> { contentModeSubject.eraseToAnyPublisher() }
    
    private var catalogSubject = CurrentValueSubject<Catalog?, Never>(nil)
    private var contentModeSubject = CurrentValueSubject<ContentMode?, Never>(nil)
    
    init(localeIdentifiers: Set<Locale.Identifier> = []) {
        _localeIdentifiers = localeIdentifiers
    }
    
    func setStorageMode(_ mode: StorageMode) {
//        let fileManager = FileManager.default
//        let identifier = Bundle.main.bundleIdentifier ?? "com.richardpiazza.lingua"
//        var url = URL.cachesDirectory
//        url = url.appending(path: identifier, directoryHint: .isDirectory)
//        url = url.appending(path: "emulation", directoryHint: .isDirectory)
//        do {
//            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
//            catalogSubject.value = try FilesystemCatalog(url: url)
//        } catch {
//            print(error)
//        }
    }
    
    func setContentMode(_ mode: ContentMode?) {
        contentModeSubject.value = mode
    }
    
    func resetStorage() {
        catalogSubject.value = nil
    }
    
    func localeIdentifiers() -> Set<Locale.Identifier> {
        _localeIdentifiers
    }
}
