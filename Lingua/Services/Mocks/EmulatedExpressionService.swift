import Foundation
import Combine
import TranslationCatalog

class EmulatedExpressionService: ExpressionService {
    
    var expressions: [TranslationCatalog.Expression]
    
    init(expressions: [TranslationCatalog.Expression] = [
        .preview,
        .preview_new
    ]) {
        self.expressions = expressions
    }
    
    func expressions(for contentScheme: ContentScheme) -> AnyPublisher<[TranslationCatalog.Expression], Never> {
        switch contentScheme {
        case .catalog:
            return Just(expressions).eraseToAnyPublisher()
        case .project:
            return Just(expressions).eraseToAnyPublisher()
        }
    }
    
    func createExpression(_ localizationKey: String, contentScheme: ContentScheme) throws -> TranslationCatalog.Expression {
        throw CocoaError(.featureUnsupported)
    }
    
    func updateExpression(
        _ expression: TranslationCatalog.Expression,
        update: TranslationCatalog.GenericExpressionUpdate,
        contentScheme: ContentScheme
    ) throws {
        throw CocoaError(.featureUnsupported)
    }
    
    func deleteExpression(_ expression: TranslationCatalog.Expression) throws {
        throw CocoaError(.featureUnsupported)
    }
}

extension TranslationCatalog.Expression {
    static let preview = TranslationCatalog.Expression(
        id: UUID(uuidString: "DC834BE5-04B2-4682-87A2-BCF799DD2A1A")!,
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
    
    static let preview_new = TranslationCatalog.Expression(
        id: .zero,
        key: "",
        name: "",
        defaultLanguage: .en,
        context: nil,
        feature: nil,
        translations: []
    )
}
