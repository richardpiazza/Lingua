import SwiftUI
import TranslationCatalog

struct ExpressionView: View {
    
    @EnvironmentObject var stateManager: StateManager
    @EnvironmentObject var expressionManager: ExpressionManager
    @EnvironmentObject var translationManager: TranslationManager
    @State private var equalWidths: CGFloat = 100.0
    @State private var name: String = ""
    @State private var key: String = ""
    @State private var feature: String = ""
    @State private var context: String = ""
    
    let expression: Expression
    
    init(expression: Expression) {
        self.expression = expression
        name = expression.name
        key = expression.key
        feature = expression.feature ?? ""
        context = expression.context ?? ""
    }
    
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
                    value: $name,
                    onCommit: expressionManager.persist,
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
                    value: $key,
                    onCommit: expressionManager.persist,
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
                    value: $context,
                    onCommit: expressionManager.persist,
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
                    value: $feature,
                    onCommit: expressionManager.persist,
                    width: $equalWidths
                )
            }
        }
    }
    
    private var titleCaptionAlignment: TextAlignment { stateManager.horizontallyCompact ? .leading : .trailing }
    private var entryFieldPadding: EdgeInsets {
        stateManager.horizontallyCompact ? .init(top: 0, leading: 12, bottom: 0, trailing: 0) : .init()
    }
    
    private func fieldTitle(_ title: String, hint: String, width: Binding<CGFloat>) -> some View {
        HStack(alignment: .top) {
            if stateManager.horizontallyCompact {
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
            if !stateManager.horizontallyCompact {
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
            ExpressionView(expression: .preview)
            
            ExpressionView(expression: .preview_new)
        }
        .environmentObject(StateManager.shared)
        .environmentObject(PersistenceManager.shared)
        .environmentObject(ProjectManager.shared)
        .environmentObject(ExpressionManager.shared)
        .environmentObject(TranslationManager.shared)
    }
}
