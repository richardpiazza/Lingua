import Foundation
import Combine
import TranslationCatalog

protocol ExpressionService {
    var expressions: AnyPublisher<[TranslationCatalog.Expression], Never> { get }
    func setQuery(_ query: String)
    func monitorExpression(_ id: TranslationCatalog.Expression.ID) -> AnyPublisher<TranslationCatalog.Expression, Error>
    func createExpression(_ localizationKey: String) throws -> TranslationCatalog.Expression
    func deleteExpressions(_ indexSet: IndexSet)
    func deleteExpression(_ expression: TranslationCatalog.Expression) throws
    func updateExpression(_ id: TranslationCatalog.Expression.ID, update: GenericExpressionUpdate) throws
}

extension ExpressionService {
    func monitorExpression(_ id: TranslationCatalog.Expression.ID) -> AnyPublisher<TranslationCatalog.Expression, Error> {
        expressions
            .tryMap { collection -> TranslationCatalog.Expression in
                guard let expression = collection.first(where: { $0.id == id }) else {
                    throw CatalogError.expressionID(id)
                }
                
                return expression
            }
            .eraseToAnyPublisher()
    }
}
