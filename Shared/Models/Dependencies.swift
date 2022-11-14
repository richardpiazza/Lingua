import Foundation
import CodeQuickKit

class Dependencies: DependencySupplier {
    
    lazy var catalogService: CatalogService = .init()
    lazy var projectService: ProjectService = .init()
    lazy var expressionService: ExpressionService = .init()
    lazy var translationService: TranslationService = .init()
    
    func supply(cache: DependencyCache) {
        cache.cache { self.catalogService }
        cache.cache { self.projectService }
        cache.cache { self.expressionService }
        cache.cache { self.translationService }
    }
}
