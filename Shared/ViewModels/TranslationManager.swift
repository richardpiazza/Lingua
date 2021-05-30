import Foundation
import TranslationCatalog

class TranslationManager: ObservableObject {
    
    static let shared: TranslationManager = .init(expressionManager: .shared, persistenceManager: .shared)
    
    private let expressionManager: ExpressionManager
    private let persistenceManager: PersistenceManager
    
    @Published var expression: Expression?
    @Published var confirmDelete: Bool = false
    @Published var showError: Bool = false
    var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    
    private init(expressionManager: ExpressionManager, persistenceManager: PersistenceManager) {
        self.expressionManager = expressionManager
        self.persistenceManager = persistenceManager
    }
}

extension TranslationManager {
    func deleteExpression() {
        guard let expression = self.expression else {
            return
        }
        
        expressionManager.deleteExpression(expression) { result in
            switch result {
            case .failure(let error):
                self.error = error
            case .success:
                self.expression = nil
            }
        }
    }
}

extension TranslationManager {
    static var preview_expression: TranslationManager {
        let manager = TranslationManager(expressionManager: .shared, persistenceManager: .shared)
        manager.expression = .preview
        return manager
    }
    
    static var preview_expression_error: TranslationManager {
        struct LocalError: LocalizedError {
            var errorDescription: String? = "Some error has occurred during an unspecified action."
        }
        
        let manager = TranslationManager(expressionManager: .shared, persistenceManager: .shared)
        manager.expression = .preview
        manager.error = LocalError()
        return manager
    }
}
