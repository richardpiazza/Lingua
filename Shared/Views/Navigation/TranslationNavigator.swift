import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    @EnvironmentObject private var translationManager: TranslationManager
    
    var body: some View {
        ScrollView {
            switch translationManager.expression {
            case .none:
                NoSelectedExpressionView()
            case .some(let expression):
                VStack(spacing: 20.0) {
                    ExpressionView(expression: expression)
                    
                    Divider()
                }
                .padding()
            }
        }
        .navigationTitle(translationManager.expression?.name ?? "")
        .toolbar {
            ToolbarItemGroup {
                #if os(macOS)
                if case let .some(expression) = translationManager.expression {
                    Text(expression.name)
                        .font(.headline)
                }
                #endif
                
                Spacer()
                
                if case .some = translationManager.expression {
                    Button(action: translationManager.deleteExpression, label: {
                        Image(systemName: "trash")
                    })
                }
            }
        }
    }
}

struct TranslationNavigator_Previews: PreviewProvider {
    static var previews: some View {
        TranslationNavigator()
            .environmentObject(StateManager.shared)
            .environmentObject(PersistenceManager.shared)
            .environmentObject(ProjectManager.shared)
            .environmentObject(ExpressionManager.shared)
            .environmentObject(TranslationManager.shared)
    }
}
