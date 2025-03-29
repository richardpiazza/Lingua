import Combine
import Foundation
import Infuse
import LocaleSupport
import Logging
import TranslationCatalog

class LinguaExpressionService: ExpressionService {
    
    private struct ExpressionComparator: SortComparator {
        var order: SortOrder = .forward
        
        func compare(_ lhs: TranslationCatalog.Expression, _ rhs: TranslationCatalog.Expression) -> ComparisonResult {
            switch order {
            case .forward:
                lhs.name.localizedCaseInsensitiveCompare(rhs.name)
            case .reverse:
                rhs.name.localizedCaseInsensitiveCompare(lhs.name)
            }
        }
    }
    
    @Resource private var logger: Logger
    @Resource private var catalogService: CatalogService
    
    private let subscriptions = SubscriptionContainer<ContentScheme, TranslationCatalog.Expression>(sort: ExpressionComparator())
    
    func expressions(for contentScheme: ContentScheme) -> AnyPublisher<[TranslationCatalog.Expression], Never> {
        guard let catalog = catalogService.catalog else {
            logger.error("Invalid Catalog", error: LinguaError.catalog)
            return Just([]).eraseToAnyPublisher()
        }
        
        return subscriptions.publisher(for: contentScheme) {
            do {
                switch contentScheme {
                case .catalog:
                    return try catalog.expressions()
                case .project(let id):
                    let query = GenericExpressionQuery.projectId(id)
                    return try catalog.expressions(matching: query)
                }
            } catch {
                return []
            }
        }
    }
    
    func createExpression(_ localizationKey: String, contentScheme: ContentScheme) throws -> TranslationCatalog.Expression {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        let key = localizationKey.uppercased()
        let query = GenericExpressionQuery.key(key)
        
        if let _ = try? catalog.expression(matching: query) {
            throw CatalogError.badQuery(query)
        }

        let language = LanguageCode(rawValue: Locale.current.language.languageCode?.identifier ?? "") ?? .default

        let expression = TranslationCatalog.Expression(
            key: key,
            name: key.capitalized,
            defaultLanguage: language,
            context: nil,
            feature: nil,
            translations: []
        )
        let expressionId = try catalog.createExpression(expression)
        
        let translation = TranslationCatalog.Translation(
            expressionId: expressionId,
            languageCode: language,
            scriptCode: nil,
            regionCode: nil,
            value: key.capitalized
        )
        let translationId = try catalog.createTranslation(translation)
        
        let new = TranslationCatalog.Expression(
            id: expressionId,
            key: expression.key,
            name: expression.name,
            defaultLanguage: expression.defaultLanguage,
            context: expression.context,
            feature: expression.feature,
            translations: [
                TranslationCatalog.Translation(
                    id: translationId,
                    expressionId: expressionId,
                    languageCode: translation.languageCode,
                    scriptCode: translation.scriptCode,
                    regionCode: translation.regionCode,
                    value: translation.value
                )
            ]
        )
        
        subscriptions.addValue(new, for: contentScheme)
        
        return new
    }
    
    func updateExpression(
        _ expression: TranslationCatalog.Expression,
        update: GenericExpressionUpdate,
        contentScheme: ContentScheme
    ) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        if case let .key(newKey) = update {
            let query = GenericExpressionQuery.key(newKey)
            
            if let _ = try? catalog.expression(matching: query) {
                throw CatalogError.badQuery(query)
            }
        }
        
        try catalog.updateExpression(expression.id, action: update)
        
        let updated: TranslationCatalog.Expression
        
        switch update {
        case .name(let name):
            updated = TranslationCatalog.Expression(
                id: expression.id,
                key: expression.key,
                name: name,
                defaultLanguage: expression.defaultLanguage,
                context: expression.context,
                feature: expression.feature,
                translations: expression.translations
            )
        case .key(let key):
            updated = TranslationCatalog.Expression(
                id: expression.id,
                key: key,
                name: expression.name,
                defaultLanguage: expression.defaultLanguage,
                context: expression.context,
                feature: expression.feature,
                translations: expression.translations
            )
        case .context(let context):
            updated = TranslationCatalog.Expression(
                id: expression.id,
                key: expression.key,
                name: expression.name,
                defaultLanguage: expression.defaultLanguage,
                context: context,
                feature: expression.feature,
                translations: expression.translations
            )
        case .feature(let feature):
            updated = TranslationCatalog.Expression(
                id: expression.id,
                key: expression.key,
                name: expression.name,
                defaultLanguage: expression.defaultLanguage,
                context: expression.context,
                feature: feature,
                translations: expression.translations
            )
        case .defaultLanguage(let languageCode):
            updated = TranslationCatalog.Expression(
                id: expression.id,
                key: expression.key,
                name: expression.name,
                defaultLanguage: languageCode,
                context: expression.context,
                feature: expression.feature,
                translations: expression.translations
            )
        }
        
        subscriptions.updateValue(updated, for: contentScheme)
    }
    
    func deleteExpression(_ expression: TranslationCatalog.Expression) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.deleteExpression(expression.id)
        
        subscriptions.removeValue(with: expression.id)
    }
}
