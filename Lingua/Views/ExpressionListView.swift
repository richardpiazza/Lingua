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
                        Label("New Expression", systemImage: "plus")
                    }
                    .keyboardShortcut(KeyEquivalent("N"), modifiers: [.command, .option])
                    .alert("Create Expression", isPresented: $showCreate) {
                        TextField("Localization Key", text: $expressionKey)

                        Button("Cancel", role: .cancel) {}

                        Button("Create") {
                            createExpression(with: expressionKey)
                            expressionKey = ""
                        }
                        .disabled(expressionKey.isEmpty)
                    } message: {
                        Text("Keys uniquely identify an expression and are used for creating localization files")
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

                    Button {
                        queryFocused = true
                    } label: {}
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
