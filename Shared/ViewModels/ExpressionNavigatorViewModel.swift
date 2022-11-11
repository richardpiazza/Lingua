import SwiftUI
import Combine
import TranslationCatalog
import LocaleSupport
import CodeQuickKit

class ExpressionNavigatorViewModel: ObservableObject {
    
    @Dependency private var catalogService: CatalogService
    @Dependency private var expressionService: ExpressionService
    
    private var expressionPublisher: AnyCancellable?
    
    @Published var expressions: [Expression] = []
    
    init() {
        expressionPublisher = expressionService
            .$expressions
            .assign(to: \.expressions, on: self)
    }
    
    func deleteExpressions(_ indexSet: IndexSet) {
        expressionService.deleteExpressions(indexSet)
    }
}
