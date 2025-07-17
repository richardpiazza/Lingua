import SwiftUI
import TranslationCatalog
import LocaleSupport

struct ExpressionListView: View {
    
    @Binding var selectedExpression: TranslationCatalog.Expression?
    var contentScheme: ContentScheme
    
    @Environment(\.storageContainer) private var storageContainer
    @State private var expressions: [TranslationCatalog.Expression] = []
    @State private var filteredExpressions: [TranslationCatalog.Expression] = []
    @State private var expressionKey: String = ""
    @State private var showCreate: Bool = false
    @State private var showImport: Bool = false
    @State private var showExport: Bool = false
    @State private var query: String = ""
    @State private var queryFocused: Bool = false
    
    private let expressionSort = ExpressionComparator()
    
    var body: some View {
        List(filteredExpressions, id: \.self, selection: $selectedExpression) { expression in
            ExpressionListItemView(expression: expression)
                .padding(8)
                .tag(expression)
        }
        .task(id: contentScheme) {
            for await values in storageContainer.expressions(for: contentScheme) {
                expressions = values.sorted(using: expressionSort)
                filter(query: query)
            }
        }
        .onChange(of: query) { _, newValue in
            filter(query: newValue)
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
                    Label("Add Expression", systemImage: "plus")
                }
                .keyboardShortcut(KeyEquivalent("N"), modifiers: .command)
                .alert("Create Expression", isPresented: $showCreate) {
                    TextField("Localization Key", text: $expressionKey)
                    
                    Button("Cancel", role: .cancel) {}
                    
                    Button("Create") {
                        createExpression(with: expressionKey)
                        expressionKey = ""
                    }
                    .disabled(expressionKey.isEmpty)
                } message: {
                    Text("These keys uniquely identify an expression and are used for creating localization files")
                }
                
                Button {
                    showImport.toggle()
                } label: {
                    Label("Import Expressions", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut(KeyEquivalent("I"), modifiers: [.command, .option])
                .sheet(isPresented: $showImport) {
                    ImportExpressionsView(
                        contentScheme: contentScheme
                    ) {
                        showImport.toggle()
                    }
                }
                
                Button {
                    showExport.toggle()
                } label: {
                    Label("Export Expressions", systemImage: "square.and.arrow.up")
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
    
    private func filter(query: String) {
        guard !query.isEmpty else {
            filteredExpressions = expressions.sorted(using: expressionSort)
            return
        }
        
        filteredExpressions = expressions
            .filter { $0.matches(query) }
            .sorted(using: expressionSort)
    }
    
    private func createExpression(with key: String) {
        do {
            let expression = try storageContainer.createExpression(key, contentScheme: contentScheme)
            selectedExpression = expression
        } catch {
        }
    }
}

#Preview {
    NavigationSplitView {
        EmptyView()
    } content: {
        ExpressionListView(
            selectedExpression: .constant(nil),
            contentScheme: .catalog
        )
    } detail: {
        EmptyView()
    }
    .environment(\.storageContainer, .inMemoryContainer)
}
