import SwiftUI
import TranslationCatalog
import CodeQuickKit
import Logging

class TranslationNavigatorViewModel: ObservableObject {
    
    @Dependency private var logger: Logger
    @Dependency private var projectService: ProjectService
    @Dependency private var expressionService: ExpressionService
    
    @Published var expression: Expression
    @Published var projects: [Project] = []
    
    init(expression: Expression = .init()) {
        self.expression = expression
        
        projectService.$projects
            .receive(on: DispatchQueue.main)
            .assign(to: &$projects)
    }
    
    func deleteExpression() {
        do {
            try expressionService.deleteExpression(expression)
        } catch {
            logger.error("Failed to Delete Expression.", error: error)
        }
    }
    
    func toggleExpressionOnProject(id: Project.ID, isSelected: Bool) {
        if isSelected {
            try? projectService.unlinkExpression(expression.id, from: id)
        } else {
            try? projectService.linkExpression(expression.id, to: id)
        }
    }
}
