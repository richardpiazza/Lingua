import SwiftUI
import TranslationCatalog

struct ExpressionListItemView: View {

    var expression: TranslationCatalog.Expression

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                if !expression.name.isEmpty {
                    Text(expression.name)
                        .font(.headline)
                } else {
                    Text(expression.key)
                        .textCase(.uppercase)
                        .font(.headline)
                }

                Text(expression.defaultValue)
                    .font(.body)
                    .italic()
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
    }
}

#Preview {
    ExpressionListItemView(
        expression: .add,
    )
    .padding()
}
