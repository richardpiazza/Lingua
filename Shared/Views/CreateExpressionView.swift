import SwiftUI
import TranslationCatalog

struct CreateExpressionView: View {
    
    class ViewModel: ObservableObject {
        @Dependency private var expressionService: ExpressionService
        
        @Published var key: String = ""
        
        init(key: String = "") {
            self.key = key
        }
        
        func createExpression(resultHandler: @escaping (Result<Expression, Swift.Error>) -> Void) {
            expressionService.createExpression(key, resultHandler: resultHandler)
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @Binding var show: Bool
    @Binding var selectedExpressionId: Expression.ID?
    @State private var error: Error?
    
    init(
        viewModel: ViewModel = .init(),
        show: Binding<Bool> = .constant(true),
        selectedExpressionId: Binding<Expression.ID?> = .constant(nil),
        error: Error? = nil
    ) {
        self.viewModel = viewModel
        _show = show
        _selectedExpressionId = selectedExpressionId
        self.error = error
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Create Expression")
                .font(.headline)
            
            VStack {
                TextField("Localization Key", text: $viewModel.key)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textCase(.uppercase)
                
                if let error = self.error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            VStack {
                Text("These keys uniquely identify an expression and are used for creating localization files")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            HStack {
                Button(action: {
                    show.toggle()
                }, label: {
                    Text("Cancel")
                })
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    viewModel.createExpression() { result in
                        switch result {
                        case .failure(let error):
                            self.error = error
                        case .success(let expression):
                            selectedExpressionId = expression.id
                            show.toggle()
                        }
                    }
                }, label: {
                    Text("Create")
                })
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: 270.0, minHeight: 270)
    }
}

struct CreateExpressionView_Previews: PreviewProvider {
    struct ExampleError: LocalizedError {
        var errorDescription: String? = "This is a localized error message that informs the user how to correct the input."
    }
    
    static var previews: some View {
        VStack {
            CreateExpressionView()
            CreateExpressionView(error: ExampleError())
        }
    }
}
