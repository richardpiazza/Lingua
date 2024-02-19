import Foundation
import Combine
import TranslationCatalog

protocol TranslationService {
    var translations: [TranslationCatalog.Translation] { get }
    var translationsPublisher: AnyPublisher<[TranslationCatalog.Translation], Never> { get }
    
    func setExpression(_ expression: Expression)
    func monitorTranslation(_ id: TranslationCatalog.Translation.ID) throws -> AnyPublisher<TranslationCatalog.Translation, Never>
    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws
    func updateTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation
}
