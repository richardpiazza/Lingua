import SwiftUI
import TranslationCatalog
import Infuse

struct CreateExpressionView: View {
    
    enum Action {
        case cancel
        case create(String)
    }
    
    private let action: (Action) -> Void
    
    @State private var key: String = ""
    
    init(
        action: @escaping (Action) -> Void
    ) {
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Create Expression")
                .font(.headline)
            
            TextField("Localization Key", text: $key)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textCase(.uppercase)
            
            Text("These keys uniquely identify an expression and are used for creating localization files")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
            
            HStack {
                Button {
                    action(.cancel)
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                
                Button {
                    action(.create(key))
                } label: {
                    Text("Create")
                }
                .frame(maxWidth: .infinity)
                .disabled(key.isEmpty)
            }
        }
        .padding()
        .frame(maxWidth: 270.0, minHeight: 270)
    }
}

#Preview {
    CreateExpressionView { _ in
    }
}
