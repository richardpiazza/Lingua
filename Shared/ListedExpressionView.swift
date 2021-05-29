import SwiftUI
import TranslationCatalog

struct ListedExpressionView: View {
    
    let expression: Expression
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading) {
                if expression.name.isEmpty {
                    Text("{Expression Name}")
                        .font(.headline)
                } else {
                    Text(expression.name)
                        .font(.headline)
                }
                
                if let context = expression.context {
                    Text(context)
                        .font(.body)
                        .italic()
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Localization Key")
                        .font(.caption)
                        .bold()
                    
                    if expression.key.isEmpty {
                        Text("{Key}")
                            .font(.callout)
                    } else {
                        Text(expression.key)
                            .font(.callout)
                    }
                }
                
                if let feature = expression.feature {
                    VStack(alignment: .leading) {
                        Text("Feature")
                            .font(.caption)
                            .bold()
                        
                        Text(feature)
                            .font(.callout)
                    }
                }
            }
        }
    }
}

struct ListedExpressionView_Previews: PreviewProvider {
    static var previews: some View {
        ListedExpressionView(expression: .preview)
        
        ListedExpressionView(expression: .preview_new)
    }
}

extension Expression {
    static var preview: Expression {
        Expression(
            uuid: UUID(uuidString: "DC834BE5-04B2-4682-87A2-BCF799DD2A1A")!,
            key: "GREETING_WELCOME",
            name: "Welcome",
            defaultLanguage: .en,
            context: "A friendly expression",
            feature: "Welcome Screen",
            translations: []
        )
    }
    
    static var preview_new: Expression {
        Expression(
            uuid: .zero,
            key: "",
            name: "",
            defaultLanguage: .en,
            context: nil,
            feature: nil,
            translations: []
        )
    }
}
