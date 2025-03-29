import Combine
import Foundation
import Infuse
import LocaleSupport
import Logging
import TranslationCatalog

class LinguaTranslationService: TranslationService {
    
    private struct TranslationComparator: SortComparator {
        var order: SortOrder = .forward
        
        func compare(_ lhs: TranslationCatalog.Translation, _ rhs: TranslationCatalog.Translation) -> ComparisonResult {
            switch order {
            case .forward:
                lhs.languageName.localizedCaseInsensitiveCompare(rhs.languageName)
            case .reverse:
                rhs.languageName.localizedCaseInsensitiveCompare(lhs.languageName)
            }
        }
    }
    
    @Resource private var logger: Logger
    @Resource private var catalogService: CatalogService
    
    private let subscriptions = SubscriptionContainer<TranslationCatalog.Expression.ID, TranslationCatalog.Translation>(sort: TranslationComparator())
    
    func translations(for expression: TranslationCatalog.Expression) -> AnyPublisher<[Translation], Never> {
        guard let catalog = catalogService.catalog else {
            logger.error("Invalid Catalog", error: LinguaError.catalog)
            return Just([]).eraseToAnyPublisher()
        }
        
        return subscriptions.publisher(for: expression.id) {
            do {
                let query = GenericTranslationQuery.expressionId(expression.id)
                return try catalog.translations(matching: query)
            } catch {
                return []
            }
        }
    }
    
    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        let id: TranslationCatalog.Translation.ID = try catalog.createTranslation(translation)
        
        let new = TranslationCatalog.Translation(
            id: id,
            expressionId: translation.expressionId,
            languageCode: translation.languageCode,
            scriptCode: translation.scriptCode,
            regionCode: translation.regionCode,
            value: translation.value
        )
        
        subscriptions.addValue(new, for: translation.expressionId)
        
        return new.id
    }
    
    func updateTranslation(_ translation: TranslationCatalog.Translation) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        let existing = try catalog.translation(translation.id)
        var languageCode = existing.languageCode
        var scriptCode = existing.scriptCode
        var regionCode = existing.regionCode
        var value = existing.value
        
        if languageCode != translation.languageCode {
            try updateTranslation(translation.id, update: .language(translation.languageCode))
            languageCode = translation.languageCode
        }
        
        if scriptCode != translation.scriptCode {
            try updateTranslation(translation.id, update: .script(translation.scriptCode))
            scriptCode = translation.scriptCode
        }
        
        if regionCode != translation.regionCode {
            try updateTranslation(translation.id, update: .region(translation.regionCode))
            regionCode = translation.regionCode
        }
        
        if value != translation.value {
            try updateTranslation(translation.id, update: .value(translation.value))
            value = translation.value
        }
        
        let updated = TranslationCatalog.Translation(
            id: existing.id,
            expressionId: existing.expressionId,
            languageCode: languageCode,
            scriptCode: scriptCode,
            regionCode: regionCode,
            value: value
        )
        
        subscriptions.updateValue(updated, for: translation.expressionId)
    }
    
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.deleteTranslation(id)
        
        subscriptions.removeValue(with: id)
    }
    
    private func updateTranslation(_ id: TranslationCatalog.Translation.ID, update: GenericTranslationUpdate) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.updateTranslation(id, action: update)
    }
}
