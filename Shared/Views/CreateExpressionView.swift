import SwiftUI
import TranslationCatalog

struct CreateExpressionView: View {
    typealias Action = (String, (Result<Expression, Error>) -> Void) -> Void
    
    let expressionManager: ExpressionManager
    let translationManager: TranslationManager
    @Binding var show: Bool
    @State var error: Error?
    
    @State private var key: String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Create Expression")
                .font(.headline)
            
            VStack {
                TextField("Localization Key", text: $key)
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
                    expressionManager.createExpression(key) { result in
                        switch result {
                        case .failure(let error):
                            self.error = error
                        case .success(let expression):
                            translationManager.expression = expression
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
            CreateExpressionView(expressionManager: .shared, translationManager: .shared, show: .constant(true))
            CreateExpressionView(expressionManager: .shared, translationManager: .shared, show: .constant(true), error: ExampleError())
        }
    }
}
