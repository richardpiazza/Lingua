import SwiftUI
import TranslationCatalog

struct ListedExpressionView: View {
    
    let expression: TranslationCatalog.Expression
    
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
                
//                if let context = expression.context {
//                    Text(context)
//                        .font(.body)
//                        .italic()
//                }
            }
            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Localization Key")
//                        .font(.caption)
//                        .bold()
//                    
//                    Text(expression.key.isEmpty ? "{Key}" : expression.key)
//                        .textCase(.uppercase)
//                        .font(.callout)
//                }
//                
//                if let feature = expression.feature {
//                    VStack(alignment: .leading) {
//                        Text("Feature")
//                            .font(.caption)
//                            .bold()
//                        
//                        Text(feature)
//                            .font(.callout)
//                    }
//                }
//            }
        }
    }
}

struct ListedExpressionView_Previews: PreviewProvider {
    static var previews: some View {
        ListedExpressionView(expression: .preview)
        
        ListedExpressionView(expression: .preview_new)
    }
}
