import SwiftUI
import TranslationCatalog
import TranslationCatalogSQLite

struct ExpressionNavigator: View {
    
    class ViewModel: ObservableObject {
        let appEnvironment: AppEnvironment
        @Published var expressions: [Expression] = []
        
        init(appEnvironment: AppEnvironment = .default) {
            self.appEnvironment = appEnvironment
            
            switch appEnvironment.contentMode {
            case .catalog:
                expressions = (try? appEnvironment.catalog.expressions()) ?? []
            case .project(let id):
                let query = SQLiteCatalog.ExpressionQuery.projectID(id)
                expressions = (try? appEnvironment.catalog.expressions(matching: query)) ?? []
            case .search(let search):
                expressions = []
            case .none:
                expressions = []
            }
        }
    }
    
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.expressions) { expression in
                NavigationLink(
                    destination: TranslationNavigator(viewModel: .init(id: expression.id)),
                    tag: expression.id,
                    selection: $appEnvironment.selectedExpression,
                    label: {
                        Text(expression.name)
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
