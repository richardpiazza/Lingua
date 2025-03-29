import Foundation
import Combine
import TranslationCatalog

protocol CatalogService {
    var catalog: Catalog? { get }
    var catalogPublisher: AnyPublisher<Catalog?, Never> { get }
    
    func setStorageMode(_ mode: StorageMode)
    func resetStorage()
    func localeIdentifiers() -> Set<Locale.Identifier>
}

extension CatalogService {
    var requireCatalogPublisher: AnyPublisher<Bool, Never> {
        catalogPublisher
            .map { $0 == nil }
            .eraseToAnyPublisher()
    }
}
