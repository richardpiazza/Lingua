import SwiftUI
import TranslationCatalog

struct ExpressionView: View {
    
    @ObservedObject var viewModel: ExpressionDetailsViewModel
    @State private var equalWidths: CGFloat = 100.0
    
    init(viewModel: ExpressionDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                fieldTitle("Name", hint: "Your reference to this Expression", width: $equalWidths)
                fieldEntry("Name", value: $viewModel.name, onCommit: viewModel.persistName, width: $equalWidths)
            }
            
            VStack(alignment: .leading) {
                fieldTitle("Localization Key", hint: "Unique value that globally identifies this Expression", width: $equalWidths)
                fieldEntry("Key", value: $viewModel.key, onCommit: viewModel.persistKey, width: $equalWidths)
            }
            
            VStack(alignment: .leading) {
                fieldTitle("Context", hint: "Hints to translators as to how this Expression is used", width: $equalWidths)
                fieldEntry("Context", value: $viewModel.context, onCommit: viewModel.persistContext, width: $equalWidths)
            }
            
            VStack(alignment: .leading) {
                fieldTitle("Feature", hint: "Classification that groups this Expression with others in your App", width: $equalWidths)
                fieldEntry("Feature", value: $viewModel.feature, onCommit: viewModel.persistFeature, width: $equalWidths)
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
}

struct ExpressionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExpressionView(viewModel: .init(expression: .preview))
            
            ExpressionView(viewModel: .init(expression: .preview_new))
        }
        .environmentObject(PersistenceManager.shared)
        .environmentObject(ProjectManager.shared)
    }
}
