import Foundation
import Combine
import LocaleSupport
import TranslationCatalog

class ExpressionService {
    
    enum Error: Swift.Error {
        case existingExpression(Expression)
    }
    
    @Dependency private var persistence: PersistenceManager
    private var monitorSubjects: [CurrentValueSubject<Expression, Never>] = []
    
    @Published var expressions: [Expression] = []
    
    init() {
        if let catalogExpressions = try? persistence.catalog.expressions() {
            expressions = catalogExpressions.sorted(by: { $0.name < $1.name })
        }
    }
    
    func setContentMode(_ contentMode: ContentMode?) {
        let _expressions: [Expression]
        switch contentMode {
        case .catalog:
            _expressions = (try? persistence.catalog.expressions()) ?? []
        case .project(let id):
            let query = GenericExpressionQuery.projectID(id)
            _expressions = (try? persistence.catalog.expressions(matching: query)) ?? []
        case .search(_):
            _expressions = []
        case .none:
            _expressions = []
        }

        expressions = _expressions.sorted(by: { $0.name < $1.name })
    }
    
    func monitorExpression(_ id: Expression.ID) throws -> AnyPublisher<Expression, Never> {
        let expression = try persistence.catalog.expression(id)
        let subject = CurrentValueSubject<Expression, Never>(expression)
        monitorSubjects.append(subject)
        return subject.eraseToAnyPublisher()
    }
    
    func createExpression(_ localizationKey: String, resultHandler: @escaping (Result<Expression, Swift.Error>) -> Void) {
        let key = localizationKey.uppercased()

        if let existing = try? persistence.catalog.expression(matching: GenericExpressionQuery.key(key)) {
            resultHandler(.failure(Error.existingExpression(existing)))
            return
        }

        let language = LanguageCode(rawValue: Locale.current.languageCode ?? "") ?? .default

        let expression = Expression(uuid: UUID(), key: key, name: key.capitalized, defaultLanguage: language, context: nil, feature: nil, translations: [])

        do {
            try persistence.catalog.createExpression(expression)
            insertExpression(expression)
            resultHandler(.success((expression)))
        } catch {
            resultHandler(.failure(error))
        }
    }
    
    func deleteExpressions(_ indexSet: IndexSet) {
        indexSet.sorted().reversed().forEach({
            let id = expressions[$0].id
            do {
                try persistence.catalog.deleteExpression(id)
                expressions.remove(at: $0)
                monitorSubjects.removeAll(where: { $0.value.id == id })
            } catch {
                print(error)
            }
        })
    }
    
    func deleteExpression(_ expression: Expression, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
        let index = expressions.firstIndex(of: expression)
        
        do {
            try persistence.catalog.deleteExpression(expression.id)
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
        if case let .key(newKey) = update {
            if let existing = try? persistence.catalog.expression(matching: GenericExpressionQuery.key(newKey)) {
                resultHandler(.failure(Error.existingExpression(existing)))
                return
            }
        }
        
        let index = expressions.firstIndex(where: { $0.id == id })
        
        do {
            try persistence.catalog.updateExpression(id, action: update)
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
