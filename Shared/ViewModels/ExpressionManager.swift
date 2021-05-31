import Foundation
import Combine
import LocaleSupport
import TranslationCatalog

class ExpressionManager: ObservableObject {
    
    enum Error: Swift.Error {
        case existingExpression(Expression)
    }
    
    static let shared: ExpressionManager = .init(persistenceManager: .shared)
    
    private let persistenceManager: PersistenceManager
    
    private init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }
}

extension ExpressionManager {
    func createExpression(_ localizationKey: String, _ resultHandler: (Result<Expression, Swift.Error>) -> Void) {
//        let key = localizationKey.uppercased()
//
//        if let existing = try? persistenceManager.catalog.expression(matching: GenericExpressionQuery.key(key)) {
//            resultHandler(.failure(Error.existingExpression(existing)))
//            return
//        }
//
//        let language = LanguageCode(rawValue: Locale.current.languageCode ?? "") ?? .default
//
//        let expression = Expression(uuid: UUID(), key: key, name: key.capitalized, defaultLanguage: language, context: nil, feature: nil, translations: [])
//
//        do {
//            try persistenceManager.catalog.createExpression(expression)
//            expressions.append(expression)
//            expressions.sort(by: { $0.name < $1.name })
//            resultHandler(.success((expression)))
//        } catch {
//            resultHandler(.failure(error))
//        }
    }
    
    func deleteExpressions(_ indexSet: IndexSet) {
//        indexSet.sorted().reversed().forEach { index in
//            let expression = expressions[index]
//            do {
//                try persistenceManager.catalog.deleteExpression(expression.id)
//                expressions.remove(at: index)
//            } catch {
//                print(error)
//            }
//        }
    }
    
    func deleteExpression(_ expression: Expression, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
//        let index = expressions.firstIndex(of: expression)
//
//        do {
//            try persistenceManager.catalog.deleteExpression(expression.id)
//            if let i = index {
//                expressions.remove(at: i)
//            }
//            resultHandler(.success(()))
//        } catch {
//            resultHandler(.failure(error))
//        }
    }
    
    func persistExpression(_ id: Expression.ID, name: String, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
//        let index = expressions.firstIndex(where: { $0.id == id })
//
//        do {
//            try persistenceManager.catalog.updateExpression(id, action: GenericExpressionUpdate.name(name))
//            if let i = index {
//                expressions[i].name = name
//            }
//            resultHandler(.success(()))
//        } catch {
//            resultHandler(.failure(error))
//        }
    }
    
    func persistExpression(_ id: Expression.ID, key: String, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
//        let index = expressions.firstIndex(where: { $0.id == id })
//
//        do {
//            try persistenceManager.catalog.updateExpression(id, action: GenericExpressionUpdate.key(key))
//            if let i = index {
//                expressions[i].key = key
//            }
//            resultHandler(.success(()))
//        } catch {
//            resultHandler(.failure(error))
//        }
    }
    
    func persistExpression(_ id: Expression.ID, context: String, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
//        let index = expressions.firstIndex(where: { $0.id == id })
//        let value = context.isEmpty ? nil : context
//
//        do {
//            try persistenceManager.catalog.updateExpression(id, action: GenericExpressionUpdate.context(value))
//            if let i = index {
//                expressions[i].context = context
//            }
//            resultHandler(.success(()))
//        } catch {
//            resultHandler(.failure(error))
//        }
    }
    
    func persistExpression(_ id: Expression.ID, feature: String, resultHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
//        let index = expressions.firstIndex(where: { $0.id == id })
//        let value = feature.isEmpty ? nil : feature
//        
//        do {
//            try persistenceManager.catalog.updateExpression(id, action: GenericExpressionUpdate.feature(value))
//            if let i = index {
//                expressions[i].feature = feature
//            }
//            resultHandler(.success(()))
//        } catch {
//            resultHandler(.failure(error))
//        }
    }
}
