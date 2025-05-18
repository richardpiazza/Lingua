import SwiftUI
import TranslationCatalog

struct ExpressionListItemView: View {
    
    var expression: TranslationCatalog.Expression
    
    private var expressionName: String {
        expression.name.isEmpty ? "{Expression Name}" : expression.name
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(expressionName)
                    .font(.headline)
                
                Text(expression.key.isEmpty ? "{Key}" : expression.key)
                    .textCase(.uppercase)
                    .font(.caption)
                
                if let translation = expression.defaultTranslation {
                    Text(translation.value)
                        .font(.body)
                        .italic()
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        ExpressionListItemView(expression: .preview)
        
        ExpressionListItemView(expression: .preview_new)
    }
}
