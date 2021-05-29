import SwiftUI
import TranslationCatalog
import TranslationCatalogSQLite

struct ExpressionNavigator: View {
    
    @State private var selectedExpression: Expression.ID?
    
    class ViewModel: ObservableObject {
        let appEnvironment: AppEnvironment
        @Published private(set) var expressions: [Expression] = []
        
        init(appEnvironment: AppEnvironment = .default) {
            self.appEnvironment = appEnvironment
            
            switch appEnvironment.contentMode {
            case .catalog:
                expressions = (try? appEnvironment.catalog.expressions()) ?? []
            case .project(let id):
                let query = SQLiteCatalog.ExpressionQuery.projectID(id)
                expressions = (try? appEnvironment.catalog.expressions(matching: query)) ?? []
            case .search(_):
                expressions = []
            case .none:
                expressions = []
            }
            
            expressions.sort(by: { $0.name < $1.name })
        }
        
        func createExpression(_ localizationKey: String, _ resultHandler: (Result<Void, Error>) -> Void) {
            struct NotImplemented: LocalizedError {
                var errorDescription: String? = "That key is already being used. Please enter a unique key."
            }
            
            let catalog = appEnvironment.catalog
            
            resultHandler(.failure(NotImplemented()))
        }
    }
    
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    @State private var displayCreateAlert: Bool = false
    
    var body: some View {
        List {
            ForEach(viewModel.expressions) { expression in
                NavigationLink(
                    destination: TranslationNavigator(viewModel: .init(state: .expression(expression.id))),
                    tag: expression.id,
                    selection: $selectedExpression,
                    label: {
                        ListedExpressionView(expression: expression)
                            .padding(8)
                    })
            }
        }
        .navigationTitle("Lingua")
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    displayCreateAlert.toggle()
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
                .keyboardShortcut(KeyEquivalent("E"), modifiers: .command)
                .sheet(isPresented: $displayCreateAlert, content: {
                    CreateExpressionView(show: $displayCreateAlert, action: viewModel.createExpression(_:_:))
                })
            }
        }
    }
}

struct ExpressionNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ExpressionNavigator(viewModel: .init())
            .environmentObject(AppEnvironment.default)
    }
}
