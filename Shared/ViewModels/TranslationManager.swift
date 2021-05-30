import Foundation
import TranslationCatalog

class TranslationManager: ObservableObject {
    
    static let shared: TranslationManager = .init(expressionManager: .shared, persistenceManager: .shared)
    
    private let expressionManager: ExpressionManager
    private let persistenceManager: PersistenceManager
    
    @Published var expression: Expression?
    
    private init(expressionManager: ExpressionManager, persistenceManager: PersistenceManager) {
        self.expressionManager = expressionManager
        self.persistenceManager = persistenceManager
    }
}

extension TranslationManager {
    func deleteExpression() {
    }
}
