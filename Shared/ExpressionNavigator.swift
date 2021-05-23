import SwiftUI
import TranslationCatalog

struct ExpressionNavigator: View {
    
    class ViewModel: ObservableObject {
        private let catalog: Catalog
        let contentMode: AppEnvironment.ContentMode
        @Published var expressions: [Expression]
        
        init(catalog: Catalog, contentMode: AppEnvironment.ContentMode) {
            self.catalog = catalog
            self.contentMode = contentMode
            
            switch contentMode {
            case .catalog:
                expressions = (try? catalog.expressions()) ?? []
            case .project(let id):
                expressions = (try? catalog.expressions(matching: LocalCatalog.Query.projectID(id))) ?? []
            case .search(let search):
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
                    destination: TranslationNavigator(viewModel: .init(catalog: appEnvironment.catalog, id: expression.id)),
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
        ExpressionNavigator(viewModel: .init(catalog: LocalCatalog.default, contentMode: .catalog))
    }
}
