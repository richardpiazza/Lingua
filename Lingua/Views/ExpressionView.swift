import SwiftUI
import TranslationCatalog

struct ExpressionView: View {

    var expression: TranslationCatalog.Expression
    var contentScheme: ContentScheme
    var onDeleteAction: () -> Void
    
    @Environment(\.storageContainer) private var storageContainer
    @State private var navigationPath: NavigationPath = NavigationPath()
    @State private var projects: [Project] = []
    @State private var linkedProjects: [Project] = []
    @State private var createProject: Bool = false
    @State private var projectName: String = ""
    @State private var confirmDelete: Bool = false
    
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
                        let linked = linkedProjects.contains(where: { $0.id == project.id })
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
                        Label("Create Project", systemImage: "plus.circle")
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
        .task {
            for await values in storageContainer.projects() {
                projects = values.sorted(using: storageContainer.projectComparator)
            }
        }
        .task(id: expression.id) {
            for await values in storageContainer.projects(for: expression.id) {
                linkedProjects = values
            }
        }
    }
    
    private func createProjectNamed(_ name: String) {
        do {
            let project = try storageContainer.createProject(name)
            toggleExpressionOnProject(id: project.id, isSelected: false)
        } catch {
        }
    }
    
    private func toggleExpressionOnProject(id: Project.ID, isSelected: Bool) {
        if isSelected {
            try? storageContainer.unlinkExpression(expression.id, from: id)
        } else {
            try? storageContainer.linkExpression(expression.id, to: id)
        }
    }
    
    private func deleteExpression() {
        try? storageContainer.deleteExpression(expression)
        onDeleteAction()
    }
    
    private func createTranslation(_ translation: TranslationCatalog.Translation) {
        _ = try? storageContainer.createTranslation(translation)
    }
    
    private func modifyTranslation(_ translation: TranslationCatalog.Translation) {
        try? storageContainer.updateTranslation(translation)
    }
}

#Preview {
    NavigationStack {
        ExpressionView(
            expression: .add,
            contentScheme: .catalog
        ) {
        }
    }
    .environment(\.storageContainer, .inMemoryContainer)
}
