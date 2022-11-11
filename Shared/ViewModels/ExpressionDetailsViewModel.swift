import Foundation
import TranslationCatalog
import CodeQuickKit

class ExpressionDetailsViewModel: ObservableObject {
    @Dependency private var expressionService: ExpressionService
    
    private let expression: Expression
    @Published var name: String = ""
    @Published var key: String = ""
    @Published var feature: String = ""
    @Published var context: String = ""
    
    init(expression: Expression) {
        self.expression = expression
        name = expression.name
        key = expression.key
        feature = expression.feature ?? ""
        context = expression.context ?? ""
    }
    
    func persistName() {
        expressionService.updateExpression(expression.id, update: .name(name)) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
    
    func persistKey() {
        expressionService.updateExpression(expression.id, update: .key(key)) { result in
            switch result {
            case .failure(let error):
                self.key = self.expression.key
                print(error)
            case .success:
                break
            }
        }
    }
    
    func persistContext() {
        expressionService.updateExpression(expression.id, update: .context(context.isEmpty ? nil : context)) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
    
    func persistFeature() {
        expressionService.updateExpression(expression.id, update: .feature(feature.isEmpty ? nil : feature)) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
}
