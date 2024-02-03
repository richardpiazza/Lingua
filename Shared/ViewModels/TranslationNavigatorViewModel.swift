import SwiftUI
import TranslationCatalog
import Infuse
import Logging

class TranslationNavigatorViewModel: ObservableObject {
    
    @Resource private var logger: Logger
    @Resource private var projectService: ProjectService
    @Resource private var expressionService: ExpressionService
    
    @Published var expression: Expression
    @Published var projects: [Project] = []
    
    init(expression: Expression = .init()) {
        self.expression = expression
        
        projectService.projectsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$projects)
    }
    
    func deleteExpression() {
        do {
            try expressionService.deleteExpression(expression)
        } catch {
            logger.error(
                "Failed to Delete Expression.",
                error: LinguaError.expressionDelete(error),
                redacting: []
            )
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
