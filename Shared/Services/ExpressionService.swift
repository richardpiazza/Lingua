import Foundation
import Combine
import TranslationCatalog

protocol ExpressionService {
    var expressions: AnyPublisher<[Expression], Never> { get }
    func setQuery(_ query: String)
    func monitorExpression(_ id: Expression.ID) -> AnyPublisher<Expression, Error>
    func createExpression(_ localizationKey: String) throws -> Expression
    func deleteExpressions(_ indexSet: IndexSet)
    func deleteExpression(_ expression: Expression) throws
    func updateExpression(_ id: Expression.ID, update: GenericExpressionUpdate) throws
}

extension ExpressionService {
    func monitorExpression(_ id: Expression.ID) -> AnyPublisher<Expression, Error> {
        expressions
            .tryMap { collection -> Expression in
                guard let expression = collection.first(where: { $0.id == id }) else {
                    throw CatalogError.expressionID(id)
                }
                
                return expression
            }
            .eraseToAnyPublisher()
    }
}
