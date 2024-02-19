import Foundation
import Combine
import TranslationCatalog

protocol CatalogService {
    var catalog: Catalog? { get }
    var contentMode: ContentMode? { get }
    
    var catalogPublisher: AnyPublisher<Catalog?, Never> { get }
    var contentModePublisher: AnyPublisher<ContentMode?, Never> { get }
    
    func setStorageMode(_ mode: StorageMode)
    func setContentMode(_ mode: ContentMode?)
    func resetStorage()
    
    func localeIdentifiers() -> Set<Locale.Identifier>
}
