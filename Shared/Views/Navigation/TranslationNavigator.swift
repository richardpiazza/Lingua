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
                    Button(action: {
                        translationManager.confirmDelete.toggle()
                    }, label: {
                        Image(systemName: "trash")
                    })
                    .alert(isPresented: $translationManager.confirmDelete, content: {
                        Alert(
                            title: Text("Delete Expression?"),
                            message: Text("Are you sure you want to remove this expression and all it's related translations?"),
                            primaryButton: .destructive(Text("Delete"), action: {
                                translationManager.deleteExpression()
                            }),
                            secondaryButton: .cancel()
                        )
                    })
                }
            }
        }
        .alert(isPresented: $translationManager.showError, content: {
            Alert(
                title: Text(translationManager.error?.localizedDescription ?? "Error")
            )
        })
    }
}

struct TranslationNavigator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TranslationNavigator()
                .environmentObject(TranslationManager.shared)
            
            TranslationNavigator()
                .environmentObject(TranslationManager.preview_expression)
            
            TranslationNavigator()
                .environmentObject(TranslationManager.preview_expression_error)
        }
        .environmentObject(StateManager.shared)
        .environmentObject(ProjectManager.shared)
        .environmentObject(ExpressionManager.shared)
    }
}
