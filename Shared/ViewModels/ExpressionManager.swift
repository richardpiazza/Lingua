import Foundation
import Combine
import LocaleSupport
import TranslationCatalog

class ExpressionManager: ObservableObject {
    
    enum Error: Swift.Error {
        case existingExpression(Expression)
    }
    
    static let shared: ExpressionManager = .init(persistenceManager: .shared, stateManager: .shared)
    
    private let persistenceManager: PersistenceManager
    private let stateManager: StateManager
    private var contentModeSubscription: AnyCancellable?
    
    @Published private(set) var expressions: [Expression] =  []
    
    private init(persistenceManager: PersistenceManager, stateManager: StateManager) {
        self.persistenceManager = persistenceManager
        self.stateManager = stateManager
        
        updateExpressionsForContentMode(stateManager.contentMode)
        
        contentModeSubscription = stateManager.$contentMode.sink { [weak self] contentMode in
            self?.updateExpressionsForContentMode(contentMode)
        }
    }
}

extension ExpressionManager {
    func createExpression(_ localizationKey: String, _ resultHandler: (Result<Expression, Swift.Error>) -> Void) {
        let key = localizationKey.uppercased()
        
        if let existing = try? persistenceManager.catalog.expression(matching: GenericExpressionQuery.key(key)) {
            resultHandler(.failure(Error.existingExpression(existing)))
            return
        }
        
        let language = LanguageCode(rawValue: Locale.current.languageCode ?? "") ?? .default
        
        let expression = Expression(uuid: UUID(), key: key, name: key.capitalized, defaultLanguage: language, context: nil, feature: nil, translations: [])
        
        do {
            try persistenceManager.catalog.createExpression(expression)
            expressions.append(expression)
            expressions.sort(by: { $0.name < $1.name })
            resultHandler(.success((expression)))
        } catch {
            resultHandler(.failure(error))
        }
    }
    
    func deleteExpressions(_ indexSet: IndexSet) {
        indexSet.sorted().reversed().forEach { index in
            let expression = expressions[index]
            do {
                try persistenceManager.catalog.deleteExpression(expression.id)
                expressions.remove(at: index)
            } catch {
                print(error)
            }
        }
    }
    
    func persist() {
    }
}

private extension ExpressionManager {
    func updateExpressionsForContentMode(_ contentMode: StateManager.ContentMode?) {
        switch contentMode {
        case .catalog:
            expressions = (try? persistenceManager.catalog.expressions()) ?? []
        case .project(let id):
            let query = GenericExpressionQuery.projectID(id)
            expressions = (try? persistenceManager.catalog.expressions(matching: query)) ?? []
        case .search(_):
            expressions = []
        case .none:
            expressions = []
        }
        
        expressions.sort(by: { $0.name < $1.name })
    }
}
