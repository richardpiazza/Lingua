import Foundation

class Dependencies: DependencyProvider {
    
    lazy var persistenceManager: PersistenceManager = .shared
    lazy var projectService: ProjectService = .init()
    lazy var expressionService: ExpressionService = .init()
    lazy var translationService: TranslationService = .init()
    
    func supply(resolver: DependencyResolver) {
        resolver.cache(dependency: { self.persistenceManager })
        resolver.cache(dependency: { self.projectService })
        resolver.cache(dependency: { self.expressionService })
        resolver.cache(dependency: { self.translationService })
    }
}
