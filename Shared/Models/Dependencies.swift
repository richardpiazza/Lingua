import Foundation
import CodeQuickKit
import Logging

class Dependencies: DependencySupplier {
    
    lazy var logger: Logger = Logger(label: "com.richardpiazza.lingua")
    lazy var catalogService: CatalogService = .init()
    lazy var projectService: ProjectService = .init()
    lazy var expressionService: ExpressionService = LinguaExpressionService()
    lazy var translationService: TranslationService = .init()
    
    func supply(cache: DependencyCache) {
        cache.cache { self.logger }
        cache.cache { self.catalogService }
        cache.cache { self.projectService }
        cache.cache { self.expressionService }
        cache.cache { self.translationService }
    }
}
