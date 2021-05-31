import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    @Binding var expression: Expression
    @State private var confirmDelete: Bool = false
    @State private var showError: Bool = false
    @State private var error: Error?
    
    var body: some View {
        ScrollView {
            if expression.id == .zero {
                NoSelectedExpressionView()
            } else {
                VStack(spacing: 20.0) {
                    ExpressionView(viewModel: .init(expression: expression))
                    
                    Divider()
                }
                .padding()
            }
        }
        .navigationTitle(expression.name)
        .toolbar {
            ToolbarItemGroup {
                #if os(macOS)
                Text(expression.name)
                    .font(.headline)
                #endif
                
                Spacer()
                
                if expression.id != .zero {
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
            TranslationNavigator(expression: .constant(.init()))
            TranslationNavigator(expression: .constant(.preview))
        }
    }
}
