import SwiftUI
import TranslationCatalog

struct ExpressionListView: View {

    @Binding var selectedExpression: TranslationCatalog.Expression?
    @Binding var showCreate: Bool
    @Binding var showImport: Bool
    @Binding var showExport: Bool
    var contentScheme: ContentScheme

    @Environment(\.storageContainer) private var storageContainer
    @State private var expressions: [TranslationCatalog.Expression] = []
    @State private var filteredExpressions: [TranslationCatalog.Expression] = []
    @State private var expressionKey: String = ""
    @State private var expressionValue: String = ""

    @State private var query: String = ""
    @State private var queryFocused: Bool = false

    var body: some View {
        List(filteredExpressions, selection: $selectedExpression) { expression in
            ExpressionListItemView(expression: expression)
                .padding(8)
                .tag(expression)
        }
        .background {
            Button {
                queryFocused = true
            } label: {}
                .keyboardShortcut(KeyEquivalent("F"), modifiers: [.command])
        }
        .task(id: contentScheme) {
            for await values in storageContainer.expressions(for: contentScheme) {
                expressions = values
                filter(query: query)
            }
        }
        .onChange(of: query) { _, newValue in
            filter(query: newValue)
        }
        .searchable(text: $query, isPresented: $queryFocused, prompt: "Search")
        .navigationTitle("Lingua")
        #if os(macOS)
        .navigationSubtitle("Translation Catalog")
        #endif
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        showCreate.toggle()
                    } label: {
                        Label("New Expression", systemImage: "plus")
                    }
                    .keyboardShortcut(KeyEquivalent("N"), modifiers: [.command, .option])
                    .alert("Create Expression", isPresented: $showCreate) {
                        TextField("Default Value", text: $expressionValue)
                        TextField("Localization Key", text: $expressionKey)

                        Button("Cancel", role: .cancel) {
                            expressionKey = ""
                            expressionValue = ""
                        }

                        Button("Create") {
                            createExpression(expressionValue, with: expressionKey)
                            expressionKey = ""
                            expressionValue = ""
                        }
                        .disabled(expressionKey.isEmpty || expressionValue.isEmpty)
                    } message: {
                        Text("Add a new expression to the catalog associated to a unique key.")
                    }

                    Button {
                        showImport.toggle()
                    } label: {
                        Label("Import Expressions", systemImage: "square.and.arrow.down")
                    }
                    .keyboardShortcut(KeyEquivalent("I"), modifiers: [.command, .option])
                    .sheet(isPresented: $showImport) {
                        NavigationStack {
                            ExpressionImporterView(
                                contentScheme: contentScheme,
                            ) {
                                showImport.toggle()
                            }
                        }
                    }

                    Button {
                        showExport.toggle()
                    } label: {
                        Label("Export Expressions", systemImage: "square.and.arrow.up")
                    }
                    .keyboardShortcut(KeyEquivalent("E"), modifiers: [.command, .option])
                    .sheet(isPresented: $showExport) {
                        NavigationStack {
                            ExpressionExporterView(
                                expressions: expressions,
                            ) {
                                showExport.toggle()
                            }
                        }
                    }
                }
            }
    }

    private func filter(query: String) {
        guard !query.isEmpty else {
            filteredExpressions = expressions
            return
        }

        filteredExpressions = expressions
            .filter { $0.matches(query) }
    }

    private func createExpression(_ value: String, with key: String) {
        do {
            let expression = try storageContainer.createExpression(value, key: key, contentScheme: contentScheme)
            selectedExpression = expression
        } catch {}
    }
}

#Preview {
    NavigationSplitView {
        EmptyView()
    } content: {
        ExpressionListView(
            selectedExpression: .constant(nil),
            showCreate: .constant(false),
            showImport: .constant(false),
            showExport: .constant(false),
            contentScheme: .catalog,
        )
    } detail: {
        EmptyView()
    }
    .environment(\.storageContainer, .inMemoryContainer)
}
