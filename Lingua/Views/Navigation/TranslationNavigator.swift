import Infuse
import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    let contentScheme: ContentScheme
    let expression: TranslationCatalog.Expression?
    let expressionService: ExpressionService
    let translationService: TranslationService
    let projectService: ProjectService
    
    @State private var projects: [Project] = []
    @State private var confirmDelete: Bool = false
    @State private var showError: Bool = false
    @State private var error: Error?
    @State private var showAddTranslation: Bool = false
    @State private var name: String = ""
    @State private var key: String = ""
    @State private var feature: String = ""
    @State private var context: String = ""
    
    init(
        contentScheme: ContentScheme,
        expression: TranslationCatalog.Expression?,
        expressionService: ExpressionService? = nil,
        translationService: TranslationService? = nil,
        projectService: ProjectService? = nil
    ) {
        self.contentScheme = contentScheme
        self.expression = expression
        if let expression {
            _name = State(wrappedValue: expression.name)
            _key = State(wrappedValue: expression.key)
            _feature = State(wrappedValue: expression.feature ?? "")
            _context = State(wrappedValue: expression.context ?? "")
        }
        
        if let expressionService {
            self.expressionService = expressionService
        } else {
            @Resource var service: ExpressionService
            self.expressionService = service
        }
        
        if let translationService {
            self.translationService = translationService
        } else {
            @Resource var service: TranslationService
            self.translationService = service
        }
        
        if let projectService {
            self.projectService = projectService
        } else {
            @Resource var service: ProjectService
            self.projectService = service
        }
    }
    
    var body: some View {
        ScrollView {
            if let expression {
                VStack(spacing: 20.0) {
                    ExpressionView(
                        name: $name,
                        key: $key,
                        context: $context,
                        feature: $feature
                    )
                    .onChange(of: name) { _, value in
                        performUpdate(.name(value))
                    }
                    .onChange(of: key) { _, value in
                        performUpdate(.key(value))
                    }
                    .onChange(of: context) { _, value in
                        performUpdate(.context(value))
                    }
                    .onChange(of: feature) { _, value in
                        performUpdate(.feature(value))
                    }
                    
                    Divider()
                    
                    Text("Translations")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TranslationsView(
                        expression: expression
                    )
                }
                .padding()
            } else {
                Text("Select an Expression.")
                    .padding(.top, 200)
            }
        }
        .toolbar {
            if let expression {
                ToolbarItemGroup {
                    Button {
                        showAddTranslation.toggle()
                    } label: {
                        Image(systemName: "plus.bubble")
                    }
                    .keyboardShortcut(KeyEquivalent("T"), modifiers: .command)
                    .sheet(isPresented: $showAddTranslation) {
                        ModifyTranslationView(
                            translation: nil
                        ) { action in
                            showAddTranslation = false
                            if case .save(let translation) = action {
                                createTranslation(translation)
                            }
                        }
                    }
                    
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .keyboardShortcut(KeyEquivalent("D"), modifiers: .command)
                    
                    Menu {
                        ForEach(projects) { project in
                            let selected = project.expressions.contains(where: { $0.id == expression.id })
                            Button {
                                toggleExpressionOnProject(id: project.id, isSelected: selected)
                            } label: {
                                Text(project.name)
                            }
                            .buttonStyle(SelectableButtonStyle(selected: selected))
                        }
                    } label: {
                        Image(systemName: "link")
                    }
                    .keyboardShortcut(KeyEquivalent("L"), modifiers: .command)
                }
            }
        }
        .navigationTitle(expression?.name ?? "")
        .alert(isPresented: $showError) {
            Alert(
                title: Text(error?.localizedDescription ?? "Error")
            )
        }
        .alert(isPresented: $confirmDelete) {
            Alert(
                title: Text("Delete Expression?"),
                message: Text("Are you sure you want to remove this expression and all it's related translations?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    deleteExpression()
                }),
                secondaryButton: .cancel()
            )
        }
        .onReceive(projectService.projectsPublisher) { value in
            projects = value
        }
    }
    
    private func deleteExpression() {
        guard let expression else {
            return
        }
        
        do {
            try expressionService.deleteExpression(expression)
        } catch {
        }
    }
    
    private func toggleExpressionOnProject(id: Project.ID, isSelected: Bool) {
        guard let expression else {
            return
        }
        
        if isSelected {
            try? projectService.unlinkExpression(expression.id, from: id)
        } else {
            try? projectService.linkExpression(expression.id, to: id)
        }
    }
    
    private func createTranslation(_ translation: TranslationCatalog.Translation) {
        guard let expression else {
            return
        }
        
        let expressionTranslation = TranslationCatalog.Translation(
            expressionId: expression.id,
            languageCode: translation.languageCode,
            scriptCode: translation.scriptCode,
            regionCode: translation.regionCode,
            value: translation.value
        )
        
        do {
            let _ = try translationService.createTranslation(expressionTranslation)
        } catch {
        }
    }
    
    private func performUpdate(_ update: GenericExpressionUpdate) {
        guard let expression else {
            return
        }
        
        do {
            try expressionService.updateExpression(expression, update: update, contentScheme: contentScheme)
        } catch {
        }
    }
}

#Preview {
    TranslationNavigator(
        contentScheme: .catalog,
        expression: .preview
    )
    .frame(width: 400)
}

struct SelectableButtonStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            if (selected) {
                Image(systemName: "checkmark")
            }
        }
    }
}
