import Foundation
import Combine
import LocaleSupport
import TranslationCatalog
import CodeQuickKit
import Logging

class ExpressionService {
    
    struct InvalidCatalog: Error {}
    
    @Dependency private var logger: Logger
    @Dependency private var catalogService: CatalogService
    
    private var monitorSubjects: [CurrentValueSubject<Expression, Never>] = []
    private var contentModeSubscription: AnyCancellable?
    
    @Published var expressions: [Expression] = []
    
    init() {
        contentModeSubscription = catalogService.$contentMode
            .sink { [weak self] contentMode in
                self?.setContentMode(contentMode)
            }
    }
    
    private func setContentMode(_ contentMode: ContentMode?) {
        guard let catalog = catalogService.catalog else {
            expressions.removeAll()
            return
        }
        
        var _expressions: [Expression]
        switch contentMode {
        case .catalog:
            _expressions = (try? catalog.expressions()) ?? []
        case .project(let id):
            let query = GenericExpressionQuery.projectID(id)
            _expressions = (try? catalog.expressions(matching: query)) ?? []
        case .search(_):
            _expressions = []
        case .none:
            _expressions = []
        }
        
        _expressions.sort(by: { $0.name < $1.name })
        
        DispatchQueue.main.async { [weak self] in
            self?.expressions = _expressions
        }
    }
    
    func monitorExpression(_ id: Expression.ID) throws -> AnyPublisher<Expression, Never> {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        let expression = try catalog.expression(id)
        let subject = CurrentValueSubject<Expression, Never>(expression)
        monitorSubjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func createExpression(_ localizationKey: String, resultHandler: @escaping (Result<Expression, Error>) -> Void) {
        guard let catalog = catalogService.catalog else {
            resultHandler(.failure(InvalidCatalog()))
            return
        }
        
        let key = localizationKey.uppercased()
        let query = GenericExpressionQuery.key(key)
        
        if let existing = try? catalog.expression(matching: query) {
            resultHandler(.failure(CatalogError.badQuery(query)))
            return
        }

        let language = LanguageCode(rawValue: Locale.current.languageCode ?? "") ?? .default

        let expression = Expression(uuid: UUID(), key: key, name: key.capitalized, defaultLanguage: language, context: nil, feature: nil, translations: [])
        let id: Expression.ID
        do {
            id = try catalog.createExpression(expression)
        } catch {
            resultHandler(.failure(error))
            return
        }
        
        insertExpression(expression)
        
        let translation = TranslationCatalog.Translation(uuid: UUID(), expressionID: id, languageCode: language, scriptCode: nil, regionCode: nil, value: key.capitalized)
        do {
            try catalog.createTranslation(translation)
            resultHandler(.success((expression)))
        } catch {
            logger.error("Failed to Create Translation.", error: error)
            resultHandler(.success((expression)))
        }
    }
    
    func deleteExpressions(_ indexSet: IndexSet) {
        guard let catalog = catalogService.catalog else {
            return
        }
        
        indexSet.sorted().reversed().forEach({
            let id = expressions[$0].id
            do {
                try catalog.deleteExpression(id)
                expressions.remove(at: $0)
                monitorSubjects.removeAll(where: { $0.value.id == id })
            } catch {
                logger.error("Failed to Delete Expressions.", error: error)
            }
        })
    }
    
    func deleteExpression(_ expression: Expression, resultHandler: @escaping (Result<Void, Error>) -> Void) {
        guard let catalog = catalogService.catalog else {
            resultHandler(.failure(InvalidCatalog()))
            return
        }
        
        let index = expressions.firstIndex(of: expression)
        
        do {
            try catalog.deleteExpression(expression.id)
            if let i = index {
                expressions.remove(at: i)
            }
            monitorSubjects.removeAll(where: { $0.value.id == expression.id })
            resultHandler(.success(()))
        } catch {
            resultHandler(.failure(error))
        }
    }
    
    func updateExpression(_ id: Expression.ID, update: GenericExpressionUpdate, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
        guard let catalog = catalogService.catalog else {
            resultHandler(.failure(InvalidCatalog()))
            return
        }
        
        if case let .key(newKey) = update {
            let query = GenericExpressionQuery.key(newKey)
            
            if let _ = try? catalog.expression(matching: query) {
                resultHandler(.failure(CatalogError.badQuery(query)))
                return
            }
        }
        
        let index = expressions.firstIndex(where: { $0.id == id })
        
        do {
            try catalog.updateExpression(id, action: update)
            if let i = index {
                switch update {
                case .name(let name):
                    expressions[i].name = name
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.name = name })
                case .key(let key):
                    expressions[i].key = key
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.key = key })
                case .context(let context):
                    expressions[i].context = context
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.context = context })
                case .feature(let feature):
                    expressions[i].feature = feature
                    monitorSubjects.filter({ $0.value.id == id }).forEach({ $0.value.feature = feature })
                default:
                    break
                }
            }
            resultHandler(.success(()))
        } catch {
            resultHandler(.failure(error))
        }
    }
}

private extension ExpressionService {
    func insertExpression(_ expression: Expression) {
        var names = expressions.map({ ($0.name, $0.id) })
        names.append((expression.name, expression.id))
        names.sort(by: { $0.0 < $1.0 })
        
        if let index = names.firstIndex(where: { $0.1 == expression.id }) {
            expressions.insert(expression, at: index)
        } else {
            expressions.append(expression)
        }
    }
}
