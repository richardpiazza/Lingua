import SwiftUI
import Combine
import TranslationCatalog
import LocaleSupport

struct ExpressionNavigator: View {
    
    @ObservedObject var viewModel: ExpressionNavigatorViewModel = .init()
    
    @State private var selectedExpressionId: Expression.ID?
    @State private var showCreate: Bool = false
    
    var body: some View {
        List {
            ForEach(viewModel.expressions) { expression in
                NavigationLink(
                    destination: TranslationNavigator(viewModel: .init(expression: expression)),
                    tag: expression.id,
                    selection: $selectedExpressionId,
                    label: {
                        ListedExpressionView(expression: expression)
                            .padding(8)
                    })
            }
            .onDelete(perform: viewModel.deleteExpressions)
        }
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
        ExpressionNavigator()
    }
}
