import Combine
import Foundation
import TranslationCatalog

protocol TranslationService {
    func translations(for expression: TranslationCatalog.Expression) -> AnyPublisher<[TranslationCatalog.Translation], Never>
    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID
    func updateTranslation(_ translation: TranslationCatalog.Translation) throws
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws
}
