import SwiftUI
import Combine
import TranslationCatalog
import LocaleSupport
import Infuse

struct ExpressionNavigator: View {
    
    private let contentScheme: ContentScheme
    private let expressionService: ExpressionService
    
    @State private var expressions: [TranslationCatalog.Expression] = []
    @State private var filteredExpressions: [TranslationCatalog.Expression] = []
    @State private var selectedExpressionId: TranslationCatalog.Expression.ID?
    @State private var showCreate: Bool = false
    @State private var showImport: Bool = false
    @State private var showExport: Bool = false
    @State private var query: String = ""
    @State private var queryFocused: Bool = false
    
    init(
        contentScheme: ContentScheme,
        expressionService: ExpressionService? = nil
    ) {
        self.contentScheme = contentScheme
        if let service = expressionService {
            self.expressionService = service
        } else {
            @Resource var dependency: ExpressionService
            self.expressionService = dependency
        }
    }
    
    var body: some View {
        List(filteredExpressions, id: \.self, selection: $selectedExpressionId) { expression in
            NavigationLink {
                TranslationNavigator(
                    contentScheme: contentScheme,
                    expression: expression
                )
            } label: {
                ListedExpressionView(expression: expression)
                    .padding(8)
            }
//            .onDeleteCommand {
//                try? expressionService.deleteExpression(expression)
//            }
        }
        .onReceive(expressionService.expressions(for: contentScheme)) { value in
            expressions = value
                .sorted(by: { $0.name < $1.name })
            if query.isEmpty {
                filteredExpressions = expressions
            } else {
                filteredExpressions = value
                    .filter { $0.matches(query) }
                    .sorted(by: { $0.name < $1.name })
            }
        }
        .onChange(of: query) { _, value in
            if value.isEmpty {
                filteredExpressions = expressions
            } else {
                filteredExpressions = expressions
                    .filter { $0.matches(value) }
                    .sorted(by: { $0.name < $1.name })
            }
        }
        .searchable(text: $query, isPresented: $queryFocused, prompt: "Search")
        .navigationTitle("Lingua")
        #if os(macOS)
        .navigationSubtitle("Localization Catalog")
        #endif
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showCreate.toggle()
                } label: {
                    Label("New", systemImage: "square.and.pencil")
                }
                .keyboardShortcut(KeyEquivalent("N"), modifiers: .command)
                .sheet(isPresented: $showCreate) {
                    CreateExpressionView { action in
                        showCreate = false
                        if case .create(let string) = action {
                            createExpression(with: string)
                        }
                    }
                }
                
                Button {
                    showImport.toggle()
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut(KeyEquivalent("I"), modifiers: [.command, .option])
                .sheet(isPresented: $showImport) {
                    Button {
                        showImport.toggle()
                    } label: {
                        Text("Hide")
                    }
                }
                
                Button {
                    showExport.toggle()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .keyboardShortcut(KeyEquivalent("E"), modifiers: [.command, .option])
                .sheet(isPresented: $showExport) {
                    ExportExpressionsView(
                        expressions: expressions
                    ) {
                        showExport.toggle()
                    }
                }
                
                Button {
                    queryFocused = true
                } label: {
                }
                .keyboardShortcut(KeyEquivalent("F"), modifiers: [.command])
            }
        }
    }
    
    private func createExpression(with key: String) {
        do {
            let expression = try expressionService.createExpression(key, contentScheme: contentScheme)
            selectedExpressionId = expression.id
        } catch {
        }
    }
}

#Preview {
    ExpressionNavigator(
        contentScheme: .catalog,
        expressionService: EmulatedExpressionService()
    )
    .frame(width: 250)
}
