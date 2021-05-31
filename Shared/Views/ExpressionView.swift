import SwiftUI
import TranslationCatalog

struct ExpressionView: View {
    
    class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var key: String = ""
        @Published var feature: String = ""
        @Published var context: String = ""
        
        var expression: Expression {
            didSet {
                name = expression.name
                key = expression.key
                feature = expression.feature ?? ""
                context = expression.context ?? ""
            }
        }
        
        init(expression: Expression) {
            self.expression = expression
            name = expression.name
            key = expression.key
            feature = expression.feature ?? ""
            context = expression.context ?? ""
        }
    }
    
    let expressionManager: ExpressionManager = .shared
    @State private var equalWidths: CGFloat = 100.0
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                fieldTitle("Name", hint: "Your reference to this Expression", width: $equalWidths)
                fieldEntry("Name", value: $viewModel.name, onCommit: persistName, width: $equalWidths)
            }
            
            VStack(alignment: .leading) {
                fieldTitle("Localization Key", hint: "Unique value that globally identifies this Expression", width: $equalWidths)
                fieldEntry("Key", value: $viewModel.key, onCommit: persistKey, width: $equalWidths)
            }
            
            VStack(alignment: .leading) {
                fieldTitle("Context", hint: "Hints to translators as to how this Expression is used", width: $equalWidths)
                fieldEntry("Context", value: $viewModel.context, onCommit: persistContext, width: $equalWidths)
            }
            
            VStack(alignment: .leading) {
                fieldTitle("Feature", hint: "Classification that groups this Expression with others in your App", width: $equalWidths)
                fieldEntry("Feature", value: $viewModel.feature, onCommit: persistFeature, width: $equalWidths)
            }
        }
    }
    
    private var titleCaptionAlignment: TextAlignment { horizontallyCompact ? .leading : .trailing }
    private var entryFieldPadding: EdgeInsets {
        horizontallyCompact ? .init(top: 0, leading: 12, bottom: 0, trailing: 0) : .init()
    }
    
    private func fieldTitle(_ title: String, hint: String, width: Binding<CGFloat>) -> some View {
        HStack(alignment: .top) {
            if horizontallyCompact {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                        .bold()
                    
                    Text(hint)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.gray)
                }
            } else {
                Text(title)
                    .font(.caption)
                    .bold()
                    .multilineTextAlignment(titleCaptionAlignment)
                    .equalWidth(width)
                
                Text(hint)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
    
    private func fieldEntry(_ title: String, value: Binding<String>, onCommit: @escaping () -> Void, width: Binding<CGFloat>) -> some View {
        HStack {
            if !horizontallyCompact {
                Text("")
                    .equalWidth(width)
            }
            
            TextField(title, text: value, onCommit: onCommit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(entryFieldPadding)
        }
    }
    
    private func persistName() {
        expressionManager.persistExpression(viewModel.expression.id, name: viewModel.name) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
    
    private func persistKey() {
        expressionManager.persistExpression(viewModel.expression.id, key: viewModel.key) { result in
            switch result {
            case .failure(let error):
                viewModel.key = viewModel.expression.key
                print(error)
            case .success:
                break
            }
        }
    }
    
    private func persistContext() {
        expressionManager.persistExpression(viewModel.expression.id, context: viewModel.context) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
    
    private func persistFeature() {
        expressionManager.persistExpression(viewModel.expression.id, feature: viewModel.feature) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
}

struct ExpressionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExpressionView(viewModel: .init(expression: .preview))
            
            ExpressionView(viewModel: .init(expression: .preview_new))
        }
        .environmentObject(PersistenceManager.shared)
        .environmentObject(ProjectManager.shared)
        .environmentObject(ExpressionManager.shared)
        .environmentObject(TranslationManager.shared)
    }
}
