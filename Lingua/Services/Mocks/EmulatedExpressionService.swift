import AsyncPlus
import Foundation
import TranslationCatalog

class EmulatedExpressionService: ExpressionService {
    
    var expressions: [TranslationCatalog.Expression]
    
    private var streams: [ContentScheme: CurrentValueAsyncSubject<[TranslationCatalog.Expression]>] = [:]
    
    init(
        expressions: [TranslationCatalog.Expression] = [
            .preview,
            .preview_new
        ]
    ) {
        self.expressions = expressions
    }
    
    func expressions(for scheme: ContentScheme) async -> AsyncStream<[TranslationCatalog.Expression]> {
        if let stream = streams[scheme] {
            return await stream.sink()
        }
        
        let stream = CurrentValueAsyncSubject<[TranslationCatalog.Expression]>([])
        streams[scheme] = stream
        
        switch scheme {
        case .catalog:
            await stream.yield(expressions)
        case .project:
            await stream.yield(expressions)
        }
        
        return await stream.sink()
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
