import AsyncPlus
import Combine
import Foundation
import Infuse
import LocaleSupport
import Logging
import TranslationCatalog

actor LinguaTranslationService: TranslationService {
    
    @Resource private var logger: Logger
    @Resource private var catalogService: CatalogService
    
    private var streams: [TranslationCatalog.Expression.ID: CurrentValueAsyncSubject<[TranslationCatalog.Translation]>] = [:]
    
    func translations(for expressionId: TranslationCatalog.Expression.ID) async -> AsyncStream<[TranslationCatalog.Translation]> {
        if let stream = streams[expressionId] {
            return await stream.sink()
        }
        
        let stream = CurrentValueAsyncSubject<[TranslationCatalog.Translation]>([])
        streams[expressionId] = stream
        
        let query = GenericTranslationQuery.expressionId(expressionId)
        if let translations = try? await catalogService.catalog?.translations(matching: query) {
            await stream.yield(translations)
        }
        
        return await stream.sink()
    }
    
    func createTranslation(_ translation: TranslationCatalog.Translation) async throws -> TranslationCatalog.Translation.ID {
        guard let catalog = await catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        let id = try catalog.createTranslation(translation)
        
        let new = TranslationCatalog.Translation(
            id: id,
            expressionId: translation.expressionId,
            languageCode: translation.languageCode,
            scriptCode: translation.scriptCode,
            regionCode: translation.regionCode,
            value: translation.value
        )
        
        if let subject = streams[translation.expressionId] {
            var values = await subject.value
            values.append(new)
            await subject.yield(values)
        }
        
        return new.id
    }
    
    func updateTranslation(_ translation: TranslationCatalog.Translation) async throws {
        guard let catalog = await catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        let existing = try catalog.translation(translation.id)
        var languageCode = existing.languageCode
        var scriptCode = existing.scriptCode
        var regionCode = existing.regionCode
        var value = existing.value
        
        if languageCode != translation.languageCode {
            try await updateTranslation(translation.id, update: .language(translation.languageCode))
            languageCode = translation.languageCode
        }
        
        if scriptCode != translation.scriptCode {
            try await updateTranslation(translation.id, update: .script(translation.scriptCode))
            scriptCode = translation.scriptCode
        }
        
        if regionCode != translation.regionCode {
            try await updateTranslation(translation.id, update: .region(translation.regionCode))
            regionCode = translation.regionCode
        }
        
        if value != translation.value {
            try await updateTranslation(translation.id, update: .value(translation.value))
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
        
        NotificationCenter.default.post(name: .translationDidChange, object: updated)
        
        if let subject = streams[existing.expressionId] {
            var values = await subject.value
            if let index = values.firstIndex(where: { $0.id == existing.id }) {
                values[index] = updated
                await subject.yield(values)
            }
        }
    }
    
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) async throws {
        guard let catalog = await catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.deleteTranslation(id)
        
        for (_, subject) in streams {
            var values = await subject.value
            if let index = values.firstIndex(where: { $0.id == id }) {
                values.remove(at: index)
                await subject.yield(values)
            }
        }
    }
    
    private func updateTranslation(_ id: TranslationCatalog.Translation.ID, update: GenericTranslationUpdate) async throws {
        guard let catalog = await catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.updateTranslation(id, action: update)
    }
}
