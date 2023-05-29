import Foundation
import TranslationCatalog
import CodeQuickKit
import Logging

class ExpressionDetailsViewModel: ObservableObject {
    
    @Dependency private var logger: Logger
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
        do {
            try expressionService.updateExpression(expression.id, update: .name(name))
        } catch {
            logger.error("Failed to Update Expression.", error: error)
        }
    }
    
    func persistKey() {
        do {
            try expressionService.updateExpression(expression.id, update: .key(key))
        } catch {
            key = self.expression.key
            logger.error("Failed to Update Expression.", error: error)
        }
    }
    
    func persistContext() {
        do {
            try expressionService.updateExpression(expression.id, update: .context(context.isEmpty ? nil : context))
        } catch {
            logger.error("Failed to Update Expression.", error: error)
        }
    }
    
    func persistFeature() {
        do {
            try expressionService.updateExpression(expression.id, update: .feature(feature.isEmpty ? nil : feature))
        } catch {
            logger.error("Failed to Update Expression.", error: error)
        }
    }
}
