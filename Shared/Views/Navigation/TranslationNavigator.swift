import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    class ViewModel: ObservableObject {
        @Dependency private var expressionService: ExpressionService
        
        @Published var expression: Expression
        
        init(expression: Expression = .init()) {
            self.expression = expression
        }
        
        func deleteExpression() {
            expressionService.deleteExpression(expression) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success:
                    break
                }
            }
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @State private var confirmDelete: Bool = false
    @State private var showError: Bool = false
    @State private var error: Error?
    
    var body: some View {
        ScrollView {
            if viewModel.expression.id == .zero {
                NoSelectedExpressionView()
            } else {
                VStack(spacing: 20.0) {
                    ExpressionView(viewModel: .init(expression: viewModel.expression))
                    
                    Divider()
                }
                .padding()
            }
        }
        .navigationTitle(viewModel.expression.name)
        .toolbar {
            ToolbarItemGroup {
                #if os(macOS)
                Text(viewModel.expression.name)
                    .font(.headline)
                #endif
                
                Spacer()
                
                if viewModel.expression.id != .zero {
                    Button(action: {
                        confirmDelete.toggle()
                    }, label: {
                        Image(systemName: "trash")
                    })
                    .alert(isPresented: $confirmDelete, content: {
                        Alert(
                            title: Text("Delete Expression?"),
                            message: Text("Are you sure you want to remove this expression and all it's related translations?"),
                            primaryButton: .destructive(Text("Delete"), action: {
                                viewModel.deleteExpression()
                            }),
                            secondaryButton: .cancel()
                        )
                    })
                }
            }
        }
        .alert(isPresented: $showError, content: {
            Alert(
                title: Text(error?.localizedDescription ?? "Error")
            )
        })
    }
}

struct TranslationNavigator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TranslationNavigator(viewModel: .init())
            TranslationNavigator(viewModel: .init(expression: .preview))
        }
    }
}
