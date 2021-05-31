import SwiftUI
import TranslationCatalog
import TranslationCatalogSQLite
import LocaleSupport

struct ExpressionNavigator: View {
    
    class ViewModel: ObservableObject {
        let persistenceManager: PersistenceManager = .shared
        
        @Published var expressions: [Expression] = []
        
        init(contentMode: MainWindow.ContentMode?) {
            switch contentMode {
            case .catalog:
                expressions = (try? persistenceManager.catalog.expressions()) ?? []
            case .project(let id):
                let query = GenericExpressionQuery.projectID(id)
                expressions = (try? persistenceManager.catalog.expressions(matching: query)) ?? []
            case .search(_):
                expressions = []
            case .none:
                expressions = []
            }
            
            expressions.sort(by: { $0.name < $1.name })
        }
    }
    
    let persistenceManager: PersistenceManager = .shared
    let expressionManager: ExpressionManager = .shared
    let translationManager: TranslationManager = .shared
    @ObservedObject var viewModel: ViewModel
    @State private var selectedExpressionId: Expression.ID?
    @State private var showCreate: Bool = false
    
    init(viewModel: ViewModel = .init(contentMode: .catalog)) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            ForEach(viewModel.expressions) { expression in
                NavigationLink(
                    destination: TranslationNavigator(expression: .constant(expression)),
                    tag: expression.id,
                    selection: $selectedExpressionId,
                    label: {
                        ListedExpressionView(expression: expression)
                            .padding(8)
                    })
            }
            .onDelete(perform: expressionManager.deleteExpressions)
        }
        .navigationTitle("Lingua")
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    showCreate.toggle()
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
                .keyboardShortcut(KeyEquivalent("E"), modifiers: .command)
                .sheet(isPresented: $showCreate, content: {
                    CreateExpressionView(expressionManager: expressionManager, translationManager: translationManager, show: $showCreate)
                })
            }
        }
    }
}

struct ExpressionNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ExpressionNavigator()
    }
}
