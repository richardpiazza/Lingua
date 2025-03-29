import SwiftUI
import Combine
import TranslationCatalog
import Logging
import Infuse

struct ExpressionView: View {

    @Binding var name: String
    @Binding var key: String
    @Binding var context: String
    @Binding var feature: String
    
    var body: some View {
        VStack(alignment: .leading) {
            ExpressionFieldView(
                value: $name,
                name: "Name",
                hint: "Your reference to this Expression",
                disabled: false
            )
            
            ExpressionFieldView(
                value: $key,
                name: "Localization Key",
                hint: "Unique value that globally identifies this Expression",
                disabled: false
            )
            
            ExpressionFieldView(
                value: $context,
                name: "Context",
                hint: "Hints to translators as to how this Expression is used",
                disabled: false
            )
            
            ExpressionFieldView(
                value: $feature,
                name: "Feature",
                hint: "Classification that groups this Expression with others in your App",
                disabled: false
            )
        }
    }
}

#Preview {
    ExpressionView(
        name: .constant(""),
        key: .constant(""),
        context: .constant(""),
        feature: .constant("")
    )
    .frame(width: 400)
}
