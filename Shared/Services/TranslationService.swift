import Foundation
import Combine
import LocaleSupport
import TranslationCatalog
import CodeQuickKit

class TranslationService {
    
    enum Error: Swift.Error {
        case notFound
    }
    
    @Dependency private var catalogService: CatalogService
    private var monitorSubjects: [CurrentValueSubject<TranslationCatalog.Translation, Never>] = []
    
    @Published var translations: [TranslationCatalog.Translation] = []
    
    func setExpression(_ expression: Expression) {
        let query = GenericTranslationQuery.expressionID(expression.id)
        let translations = ((try? catalogService.catalog.translations(matching: query)) ?? [])
            .sorted(by: { $0.languageName < $1.languageName })
        DispatchQueue.main.async { [weak self] in
            self?.translations = translations
        }
    }
    
    func monitorTranslation(_ id: TranslationCatalog.Translation.ID) throws -> AnyPublisher<TranslationCatalog.Translation, Never> {
        let translation = try catalogService.catalog.translation(id)
        let subject = CurrentValueSubject<TranslationCatalog.Translation, Never>(translation)
        monitorSubjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func createTranslation(_ translation: TranslationCatalog.Translation, resultHandler: @escaping (Result<TranslationCatalog.Translation.ID, Swift.Error>) -> Void) {
        let id: TranslationCatalog.Translation.ID
        do {
            id = try catalogService.catalog.createTranslation(translation)
        } catch {
            resultHandler(.failure(error))
            return
        }
        
        var entity = translation
        entity.uuid = id
        
        translations.append(entity)
        
        resultHandler(.success(id))
    }
    
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
        do {
            try catalogService.catalog.deleteTranslation(id)
            
            translations.removeAll(where: { $0.id == id })
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.send(completion: .finished) })
            monitorSubjects.removeAll(where: { $0.value.id == id })
            
            resultHandler(.success(()))
        } catch {
            resultHandler(.failure(error))
        }
    }
    
    func updateTranslation(_ translation: TranslationCatalog.Translation, resultHandler: @escaping (Result<TranslationCatalog.Translation, Swift.Error>) -> Void) {
        var existing: TranslationCatalog.Translation
        do {
            existing = try catalogService.catalog.translation(translation.id)
        } catch {
            resultHandler(.failure(error))
            return
        }
        
        if existing.languageCode != translation.languageCode {
            do {
                try updateTranslation(translation.id, update: .language(translation.languageCode))
                existing.languageCode = translation.languageCode
            } catch {
                resultHandler(.failure(error))
                return
            }
        }
        
        if existing.scriptCode != translation.scriptCode {
            do {
                try updateTranslation(translation.id, update: .script(translation.scriptCode))
                existing.scriptCode = translation.scriptCode
            } catch {
                resultHandler(.failure(error))
                return
            }
        }
        
        if existing.regionCode != translation.regionCode {
            do {
                try updateTranslation(translation.id, update: .region(translation.regionCode))
                existing.regionCode = translation.regionCode
            } catch {
                resultHandler(.failure(error))
                return
            }
        }
        
        if existing.value != translation.value {
            do {
                try updateTranslation(translation.id, update: .value(translation.value))
                existing.value = translation.value
            } catch {
                resultHandler(.failure(error))
                return
            }
        }
        
        resultHandler(.success(existing))
    }
    
    func updateTranslation(_ id: TranslationCatalog.Translation.ID, update: GenericTranslationUpdate, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
        let index = translations.firstIndex(where: { $0.id == id })
        
        do {
            try catalogService.catalog.updateTranslation(id, action: update)
            if let i = index {
                switch update {
                case .language(let languageCode):
                    translations[i].languageCode = languageCode
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.languageCode = languageCode })
                case .region(let regionCode):
                    translations[i].regionCode = regionCode
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.regionCode = regionCode })
                case .script(let scriptCode):
                    translations[i].scriptCode = scriptCode
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.scriptCode = scriptCode })
                case .value(let value):
                    translations[i].value = value
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.value = value })
                }
            }
            resultHandler(.success(()))
        } catch {
            resultHandler(.failure(error))
        }
    }
    
    private func updateTranslation(_ id: TranslationCatalog.Translation.ID, update: GenericTranslationUpdate) throws {
        guard let index = translations.firstIndex(where: { $0.id == id }) else {
            throw Error.notFound
        }
        
        try catalogService.catalog.updateTranslation(id, action: update)
        
        switch update {
        case .language(let languageCode):
            translations[index].languageCode = languageCode
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.languageCode = languageCode })
        case .region(let regionCode):
            translations[index].regionCode = regionCode
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.regionCode = regionCode })
        case .script(let scriptCode):
            translations[index].scriptCode = scriptCode
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.scriptCode = scriptCode })
        case .value(let value):
            translations[index].value = value
            monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.value = value })
        }
    }
}
