import Foundation
import Combine
import TranslationCatalog

class EmulatedExpressionService: ExpressionService {
    
    struct InvalidExpression: Error {}
    
    private let sourceExpressions: [Expression]
    private let expressionSubject: CurrentValueSubject<[TranslationCatalog.Expression], Never>
    
    init(expressions: [TranslationCatalog.Expression] = [
        .preview,
        .preview_new
    ]) {
        sourceExpressions = expressions
        expressionSubject = .init(expressions)
    }
    
    var expressions: AnyPublisher<[TranslationCatalog.Expression], Never> {
        expressionSubject.eraseToAnyPublisher()
    }
    
    func setQuery(_ query: String) {
        var expressions = sourceExpressions
        if !query.isEmpty {
            expressions.removeAll(where: { !$0.matches(query) })
        }
        expressionSubject.send(expressions)
    }
    
    func createExpression(_ localizationKey: String) throws -> TranslationCatalog.Expression {
        throw InvalidExpression()
    }
    
    func deleteExpressions(_ indexSet: IndexSet) {
        
    }
    
    func deleteExpression(_ expression: TranslationCatalog.Expression) throws {
        
    }
    
    func updateExpression(_ id: TranslationCatalog.Expression.ID, update: TranslationCatalog.GenericExpressionUpdate) throws {
        
    }
}

extension Expression {
    static var preview: Expression {
        Expression(
            uuid: UUID(uuidString: "DC834BE5-04B2-4682-87A2-BCF799DD2A1A")!,
            key: "GREETING_WELCOME",
            name: "Welcome",
            defaultLanguage: .en,
            context: "A friendly expression",
            feature: "Welcome Screen",
            translations: [
                .en,
                .es
            ]
        )
    }
    
    static var preview_new: Expression {
        Expression(
            uuid: .zero,
            key: "",
            name: "",
            defaultLanguage: .en,
            context: nil,
            feature: nil,
            translations: []
        )
    }
}
