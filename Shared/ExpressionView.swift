import SwiftUI
import TranslationCatalog

struct ExpressionView: View {
    
    class ViewModel: ObservableObject {
        let appEnvironment: AppEnvironment
        let expression: Expression
        
        @Published var name: String
        @Published var key: String
        @Published var feature: String
        @Published var context: String
        
        init(appEnvironment: AppEnvironment = .default, expression: Expression) {
            self.appEnvironment = appEnvironment
            self.expression = expression
            name = expression.name
            key = expression.key
            feature = expression.feature ?? ""
            context = expression.context ?? ""
        }
        
        func persist() {
            
        }
    }
    
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    @State private var equalWidths: CGFloat = 100.0
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                fieldTitle(
                    "Name",
                    hint: "Your reference to this Expression",
                    width: $equalWidths
                )
                
                fieldEntry(
                    "Name",
                    value: $viewModel.name,
                    onCommit: viewModel.persist,
                    width: $equalWidths
                )
            }
            
            VStack(alignment: .leading) {
                fieldTitle(
                    "Localization Key",
                    hint: "Unique value that globally identifies this Expression",
                    width: $equalWidths
                )
                
                fieldEntry(
                    "Key",
                    value: $viewModel.key,
                    onCommit: viewModel.persist,
                    width: $equalWidths
                )
            }
            
            VStack(alignment: .leading) {
                fieldTitle(
                    "Context",
                    hint: "Hints to translators as to how this Expression is used",
                    width: $equalWidths
                )
                
                fieldEntry(
                    "Context",
                    value: $viewModel.context,
                    onCommit: viewModel.persist,
                    width: $equalWidths
                )
            }
            
            VStack(alignment: .leading) {
                fieldTitle(
                    "Feature",
                    hint: "Classification that groups this Expression with others in your App",
                    width: $equalWidths
                )
                
                fieldEntry(
                    "Feature",
                    value: $viewModel.feature,
                    onCommit: viewModel.persist,
                    width: $equalWidths
                )
            }
        }
    }
    
    private var titleCaptionAlignment: TextAlignment { appEnvironment.horizontallyCompact ? .leading : .trailing }
    private var entryFieldPadding: EdgeInsets {
        appEnvironment.horizontallyCompact ? .init(top: 0, leading: 12, bottom: 0, trailing: 0) : .init()
    }
    
    private func fieldTitle(_ title: String, hint: String, width: Binding<CGFloat>) -> some View {
        HStack(alignment: .top) {
            if appEnvironment.horizontallyCompact {
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
            if !appEnvironment.horizontallyCompact {
                Text("")
                    .equalWidth(width)
            }
            
            TextField(title, text: value, onCommit: onCommit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(entryFieldPadding)
        }
    }
}

struct ExpressionView_Previews: PreviewProvider {
    static var previews: some View {
        ExpressionView(viewModel: .init(expression: .preview))
        
        ExpressionView(viewModel: .init(expression: .preview_new))
    }
}
