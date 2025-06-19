import Combine
import Foundation
import TranslationCatalog

protocol TranslationService {
    func translations(for expressionId: TranslationCatalog.Expression.ID) async -> AsyncStream<[TranslationCatalog.Translation]>
    func createTranslation(_ translation: TranslationCatalog.Translation) async throws -> TranslationCatalog.Translation.ID
    func updateTranslation(_ translation: TranslationCatalog.Translation) async throws
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) async throws
}
