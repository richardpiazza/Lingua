import Foundation
import TranslationCatalog

class TranslationManager: ObservableObject {
    
    static let shared: TranslationManager = .init(persistenceManager: .shared)
    
    private let persistenceManager: PersistenceManager
    
    @Published var expression: Expression?
    @Published var confirmDelete: Bool = false
    @Published var showError: Bool = false
    var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    
    private init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }
}

extension TranslationManager {
    static var preview_expression: TranslationManager {
        let manager = TranslationManager(persistenceManager: .shared)
        manager.expression = .preview
        return manager
    }
    
    static var preview_expression_error: TranslationManager {
        struct LocalError: LocalizedError {
            var errorDescription: String? = "Some error has occurred during an unspecified action."
        }
        
        let manager = TranslationManager(persistenceManager: .shared)
        manager.expression = .preview
        manager.error = LocalError()
        return manager
    }
}
