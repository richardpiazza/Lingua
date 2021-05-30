import SwiftUI
import TranslationCatalog
import TranslationCatalogSQLite
import LocaleSupport

struct ExpressionNavigator: View {
    
    @EnvironmentObject private var expressionManager: ExpressionManager
    @EnvironmentObject private var translationManager: TranslationManager
    @State private var displayCreateAlert: Bool = false
    
    var body: some View {
        List {
            ForEach(expressionManager.expressions) { expression in
                NavigationLink(
                    destination: TranslationNavigator(),
                    tag: expression,
                    selection: $translationManager.expression,
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
                    displayCreateAlert.toggle()
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
                .keyboardShortcut(KeyEquivalent("E"), modifiers: .command)
                .sheet(isPresented: $displayCreateAlert, content: {
                    CreateExpressionView(show: $displayCreateAlert) { key, completion in
                        expressionManager.createExpression(key) { result in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(let expression):
                                translationManager.expression = expression
                                completion(.success(expression))
                            }
                        }
                    }
                })
            }
        }
    }
}

struct ExpressionNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ExpressionNavigator()
            .environmentObject(ExpressionManager.shared)
            .environmentObject(TranslationManager.shared)
    }
}
