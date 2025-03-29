import Combine
import Foundation
import TranslationCatalog

protocol ExpressionService {
    func expressions(for contentScheme: ContentScheme) -> AnyPublisher<[TranslationCatalog.Expression], Never>
    func createExpression(_ localizationKey: String, contentScheme: ContentScheme) throws -> TranslationCatalog.Expression
    func updateExpression(_ expression: TranslationCatalog.Expression, update: GenericExpressionUpdate, contentScheme: ContentScheme) throws
    func deleteExpression(_ expression: TranslationCatalog.Expression) throws
}
