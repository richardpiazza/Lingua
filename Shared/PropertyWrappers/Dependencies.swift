import Foundation

class Dependencies: DependencyProvider {
    
    lazy var catalogService: CatalogService = .init()
    lazy var projectService: ProjectService = .init()
    lazy var expressionService: ExpressionService = .init()
    lazy var translationService: TranslationService = .init()
    
    func supply(resolver: DependencyResolver) {
        resolver.cache(dependency: { self.catalogService })
        resolver.cache(dependency: { self.projectService })
        resolver.cache(dependency: { self.expressionService })
        resolver.cache(dependency: { self.translationService })
    }
}
