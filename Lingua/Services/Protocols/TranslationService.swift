import Combine
import Foundation
import TranslationCatalog

protocol TranslationService {
    func translations(for expressionId: TranslationCatalog.Expression.ID) async -> AsyncStream<[TranslationCatalog.Translation]>
    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID
    func updateTranslation(_ translation: TranslationCatalog.Translation) throws
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws
}
