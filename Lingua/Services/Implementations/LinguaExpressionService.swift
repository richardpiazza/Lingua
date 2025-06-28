import AsyncPlus
import Combine
import Foundation
import Infuse
import LocaleSupport
import Logging
import TranslationCatalog

class LinguaExpressionService: ExpressionService {
    
    @Resource private var logger: Logger
    @Resource private var catalogService: CatalogService
    
    private var streams: [ContentScheme: CurrentValueAsyncSubject<[TranslationCatalog.Expression]>] = [:]
    private var expressionsSubscription: AnyCancellable?
    private var notificationSubscription: AnyCancellable?
    
    init() {
        expressionsSubscription = catalogService.catalogPublisher
            .compactMap { $0 }
            .map { (try? $0.expressions()) ?? [] }
            .sink { [weak self] expressions in
            }
        
        notificationSubscription = NotificationCenter.default
            .publisher(for: .translationDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.updateTranslation(notification)
            }
    }
    
    func expressions(for scheme: ContentScheme) async -> AsyncStream<[TranslationCatalog.Expression]> {
        if let stream = streams[scheme] {
            return await stream.sink()
        }
        
        let stream = CurrentValueAsyncSubject<[TranslationCatalog.Expression]>([])
        streams[scheme] = stream
        
        switch scheme {
        case .catalog:
            if let expressions = try? catalogService.catalog?.expressions() {
                await stream.yield(expressions)
            }
        case .project(let id):
            let query = GenericExpressionQuery.projectId(id)
            if let expressions = try? catalogService.catalog?.expressions(matching: query) {
                await stream.yield(expressions)
            }
        }
        
        return await stream.sink()
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
        
        Task {
            if let subject = streams[.catalog] {
                var values = await subject.value
                values.append(new)
                await subject.yield(values)
            }
            
            if let subject = streams[contentScheme], contentScheme != .catalog {
                var values = await subject.value
                values.append(new)
                await subject.yield(values)
            }
        }
        
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
        
        Task {
            if let subject = streams[.catalog] {
                var values = await subject.value
                if let index = values.firstIndex(where: { $0.id == expression.id }) {
                    values[index] = updated
                    await subject.yield(values)
                }
            }
            
            if let subject = streams[contentScheme], contentScheme != .catalog {
                var values = await subject.value
                if let index = values.firstIndex(where: { $0.id == expression.id }) {
                    values[index] = updated
                    await subject.yield(values)
                }
            }
        }
    }
    
    func deleteExpression(_ expression: TranslationCatalog.Expression) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.deleteExpression(expression.id)
        
        Task {
            for (_, subject) in streams {
                var values = await subject.value
                if let index = values.firstIndex(where: { $0.id == expression.id }) {
                    values.remove(at: index)
                    await subject.yield(values)
                }
            }
        }
    }
    
    private func updateTranslation(_ notification: Notification) {
        guard let translation = notification.object as? TranslationCatalog.Translation else {
            return
        }
        
        Task {
            for (_, subject) in streams {
                var values = await subject.value
                guard let index = values.firstIndex(where: { $0.id == translation.expressionId }) else {
                    continue
                }
                
                let expression = values[index]
                guard let translationIndex = expression.translations.firstIndex(where: { $0.id == translation.id }) else {
                    continue
                }
                
                var translations = expression.translations
                translations[translationIndex] = translation
                
                let updatedExpression = TranslationCatalog.Expression(
                    expression: expression,
                    translations: translations
                )
                
                values[index] = updatedExpression
                await subject.yield(values)
            }
        }
    }
}
