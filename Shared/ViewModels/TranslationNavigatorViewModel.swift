import SwiftUI
import TranslationCatalog
import CodeQuickKit
import Logging

class TranslationNavigatorViewModel: ObservableObject {
    
    @Dependency private var logger: Logger
    @Dependency private var expressionService: ExpressionService
    
    @Published var expression: Expression
    
    init(expression: Expression = .init()) {
        self.expression = expression
    }
    
    func deleteExpression() {
        expressionService.deleteExpression(expression) { result in
            switch result {
            case .failure(let error):
                self.logger.error("Failed to Delete Expression.", error: error)
            case .success:
                break
            }
        }
    }
}
