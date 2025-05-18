import SwiftUI
import Combine
import TranslationCatalog
import Logging
import Infuse

struct ExpressionView: View {

    var expression: TranslationCatalog.Expression
    var contentScheme: ContentScheme
    var projects: [Project]
    var expressionService: ExpressionService?
    var translationService: TranslationService?
    var projectService: ProjectService?
    var onDeleteAction: () -> Void
    
    @State private var navigationPath: NavigationPath = NavigationPath()
    @State private var createProject: Bool = false
    @State private var projectName: String = ""
    @State private var confirmDelete: Bool = false
    
    private var resolvedExpressionService: ExpressionService {
        if let expressionService {
            expressionService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    private var resolvedTranslationService: TranslationService {
        if let translationService {
            translationService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    private var resolvedProjectService: ProjectService {
        if let projectService {
            projectService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ExpressionFormView(
                expression: expression,
                contentScheme: contentScheme
            )
            .navigationDestination(for: TranslationCatalog.Translation.self) { translation in
                TranslationView(translation: translation) { action in
                    switch action {
                    case .cancel:
                        navigationPath.removeLast()
                    case .save(let value):
                        navigationPath.removeLast()
                        if value.id == .zero {
                            createTranslation(value)
                        } else {
                            modifyTranslation(value)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    ForEach(projects) { project in
                        let linked = linkedToProject(project)
                        Button {
                            toggleExpressionOnProject(id: project.id, isSelected: linked)
                        } label: {
                            Label {
                                Text(project.name)
                            } icon: {
                                if linked {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .labelStyle(.titleAndIcon)
                    }
                    
                    if !projects.isEmpty {
                        Divider()
                    }
                    
                    Button {
                        createProject = true
                    } label: {
                        Label("Create Project", systemImage: "plus")
                    }
                    .labelStyle(.titleAndIcon)
                } label: {
                    Label("Link Project", systemImage: "link")
                }
                .alert("Create Project", isPresented: $createProject) {
                    TextField("Name", text: $projectName)
                    
                    Button("Cancel", role: .cancel) {}
                    
                    Button {
                        createProjectNamed(projectName)
                        projectName = ""
                    } label: {
                        Text("Create")
                    }
                    .disabled(projectName.isEmpty)
                } message: {
                    Text("What would you like to name your new project?")
                }
                
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Label("Delete Expression", systemImage: "trash")
                }
                .alert("Delete Expression?", isPresented: $confirmDelete) {
                    Button(role: .cancel) {
                        confirmDelete = false
                    } label: {
                        Text("Cancel")
                    }
                    
                    Button(role: .destructive) {
                        deleteExpression()
                    } label: {
                        Text("Delete")
                    }
                } message: {
                    Text("Are you sure you want to remove this expression and all it's related translations?")
                }
            }
        }
    }
    
    private func createProjectNamed(_ name: String) {
        do {
            let project = try resolvedProjectService.createProject(name)
            toggleExpressionOnProject(id: project.id, isSelected: false)
        } catch {
        }
    }
    
    private func linkedToProject(_ project: Project) -> Bool {
        guard let project = projects.first(where: { $0.id == project.id }) else {
            return false
        }
        
        return project.expressions.contains(where: { $0.id == expression.id })
    }
    
    private func toggleExpressionOnProject(id: Project.ID, isSelected: Bool) {
        if isSelected {
            try? resolvedProjectService.unlinkExpression(expression.id, from: id)
        } else {
            try? resolvedProjectService.linkExpression(expression.id, to: id)
        }
    }
    
    private func deleteExpression() {
        try? resolvedExpressionService.deleteExpression(expression)
        onDeleteAction()
    }
    
    private func createTranslation(_ translation: TranslationCatalog.Translation) {
        _ = try? resolvedTranslationService.createTranslation(translation)
    }
    
    private func modifyTranslation(_ translation: TranslationCatalog.Translation) {
        try? resolvedTranslationService.updateTranslation(translation)
    }
}

#Preview {
    NavigationStack {
        ExpressionView(
            expression: .preview,
            contentScheme: .catalog,
            projects: [],
            expressionService: EmulatedExpressionService(),
            projectService: EmulatedProjectService()
        ) {
        }
    }
}
