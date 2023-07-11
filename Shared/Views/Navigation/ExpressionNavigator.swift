import SwiftUI
import Combine
import TranslationCatalog
import LocaleSupport

struct ExpressionNavigator: View {
    
    @ObservedObject var viewModel: ExpressionNavigatorViewModel = .init()
    
    @State private var selectedExpressionId: Expression.ID?
    @State private var showCreate: Bool = false
    
    var body: some View {
        List(viewModel.expressions, id: \.self, selection: $selectedExpressionId) { expression in
            NavigationLink(value: expression) {
                ListedExpressionView(expression: expression)
                    .padding(8)
            }
        }
//        .onDelete(perform: viewModel.deleteExpressions)
        .navigationDestination(for: Expression.self, destination: { expression in
            TranslationNavigator(viewModel: .init(expression: expression))
        })
        .navigationTitle("Lingua")
        #if os(macOS)
        .navigationSubtitle("Localization Catalog")
        #endif
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    showCreate.toggle()
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
                .keyboardShortcut(KeyEquivalent("E"), modifiers: .command)
                .sheet(isPresented: $showCreate, content: {
                    CreateExpressionView(show: $showCreate, selectedExpressionId: $selectedExpressionId)
                })
            }
        }
    }
}

struct ExpressionNavigator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExpressionNavigator()
        }
    }
}
