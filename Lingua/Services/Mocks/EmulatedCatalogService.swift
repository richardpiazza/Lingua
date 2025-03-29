import Foundation
import Combine
import TranslationCatalog
import TranslationCatalogFilesystem
import LocaleSupport

class EmulatedCatalogService: CatalogService {
    
    var locales: Set<Locale.Identifier>
    
    var catalog: Catalog? { catalogSubject.value }
    var catalogPublisher: AnyPublisher<Catalog?, Never> { catalogSubject.eraseToAnyPublisher() }
    
    let catalogSubject = CurrentValueSubject<Catalog?, Never>(nil)
    
    init(locales: Set<Locale.Identifier> = []) {
        self.locales = locales
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
    
    func resetStorage() {
        catalogSubject.value = nil
    }
    
    func localeIdentifiers() -> Set<Locale.Identifier> {
        locales
    }
}
