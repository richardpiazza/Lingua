import Foundation
import Combine
import LocaleSupport
import TranslationCatalog
import Infuse

class LinguaTranslationService: TranslationService {
    
    struct InvalidCatalog: Error {}
    
    var translations: [Translation] { translationsSubject.value }
    var translationsPublisher: AnyPublisher<[Translation], Never> { translationsSubject.eraseToAnyPublisher() }
    
    @Resource private var catalogService: CatalogService
    private var monitorSubjects: [CurrentValueSubject<TranslationCatalog.Translation, Never>] = []
    private var translationsSubject = CurrentValueSubject<[TranslationCatalog.Translation], Never>([])
    
    func setExpression(_ expression: Expression) {
        guard let catalog = catalogService.catalog else {
            return
        }
        
        let query = GenericTranslationQuery.expressionID(expression.id)
        let translations = ((try? catalog.translations(matching: query)) ?? [])
            .sorted(by: { $0.languageName < $1.languageName })
        translationsSubject.value = translations
    }
    
    func monitorTranslation(_ id: TranslationCatalog.Translation.ID) throws -> AnyPublisher<TranslationCatalog.Translation, Never> {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        let translation = try catalog.translation(id)
        let subject = CurrentValueSubject<TranslationCatalog.Translation, Never>(translation)
        monitorSubjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        let id: TranslationCatalog.Translation.ID = try catalog.createTranslation(translation)
        
        var entity = translation
        entity.uuid = id
        
        translationsSubject.value.append(entity)
        
        return id
    }
    
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        try catalog.deleteTranslation(id)
        
        translationsSubject.value.removeAll(where: { $0.id == id })
        monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.send(completion: .finished) })
        monitorSubjects.removeAll(where: { $0.value.id == id })
    }
    
    func updateTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        var existing: TranslationCatalog.Translation = try catalog.translation(translation.id)
        
        if existing.languageCode != translation.languageCode {
            try updateTranslation(translation.id, update: .language(translation.languageCode))
            existing.languageCode = translation.languageCode
        }
        
        if existing.scriptCode != translation.scriptCode {
            try updateTranslation(translation.id, update: .script(translation.scriptCode))
            existing.scriptCode = translation.scriptCode
        }
        
        if existing.regionCode != translation.regionCode {
            try updateTranslation(translation.id, update: .region(translation.regionCode))
            existing.regionCode = translation.regionCode
        }
        
        if existing.value != translation.value {
            try updateTranslation(translation.id, update: .value(translation.value))
            existing.value = translation.value
        }
        
        return existing
    }
    
    private func updateTranslation(_ id: TranslationCatalog.Translation.ID, update: GenericTranslationUpdate) throws {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        guard let index = translations.firstIndex(where: { $0.id == id }) else {
            throw CatalogError.translationID(id)
        }
        
        try catalog.updateTranslation(id, action: update)
        
        switch update {
        case .language(let languageCode):
            translationsSubject.value[index].languageCode = languageCode
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.languageCode = languageCode })
        case .region(let regionCode):
            translationsSubject.value[index].regionCode = regionCode
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.regionCode = regionCode })
        case .script(let scriptCode):
            translationsSubject.value[index].scriptCode = scriptCode
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.scriptCode = scriptCode })
        case .value(let value):
            translationsSubject.value[index].value = value
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.value = value })
        }
    }
}
