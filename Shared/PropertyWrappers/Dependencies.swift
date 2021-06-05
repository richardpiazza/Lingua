import Foundation

class Dependencies: DependencyProvider {
    
    lazy var persistenceManager: PersistenceManager = .shared
    lazy var expressionService: ExpressionService = .init()
    
    func supply(resolver: DependencyResolver) {
        resolver.cache(dependency: { self.persistenceManager })
        resolver.cache(dependency: { self.expressionService })
    }
}
