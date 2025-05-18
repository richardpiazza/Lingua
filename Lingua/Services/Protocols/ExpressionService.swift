import TranslationCatalog

protocol ExpressionService {
    func expressions(for scheme: ContentScheme) async -> AsyncStream<[TranslationCatalog.Expression]>
    func createExpression(_ localizationKey: String, contentScheme: ContentScheme) throws -> TranslationCatalog.Expression
    func updateExpression(_ expression: TranslationCatalog.Expression, update: GenericExpressionUpdate, contentScheme: ContentScheme) throws
    func deleteExpression(_ expression: TranslationCatalog.Expression) throws
}
