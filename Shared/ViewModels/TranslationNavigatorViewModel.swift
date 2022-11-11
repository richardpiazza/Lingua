import SwiftUI
import TranslationCatalog
import CodeQuickKit

class TranslationNavigatorViewModel: ObservableObject {
    @Dependency private var expressionService: ExpressionService
    
    @Published var expression: Expression
    
    init(expression: Expression = .init()) {
        self.expression = expression
    }
    
    func deleteExpression() {
        expressionService.deleteExpression(expression) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
}
