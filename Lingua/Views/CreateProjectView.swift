import SwiftUI
import TranslationCatalog

struct CreateProjectView: View {
    
    enum Action {
        case cancel
        case create(String)
    }
    
    private let action: (Action) -> Void
    
    @State private var name: String = ""
    
    init(
        action: @escaping (Action) -> Void
    ) {
        self.action = action
    }
    
    var body: some View {
        VStack {
            Text("Create Project")
                .font(.headline)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack(spacing: 16) {
                Button(role: .cancel) {
                    action(.cancel)
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    action(.create(name))
                } label: {
                    Text("Create")
                        .foregroundColor(.accentColor)
                }
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(idealWidth: 270.0, maxWidth: 270.0, idealHeight: 270)
    }
}

#Preview {
    CreateProjectView { _ in
    }
}
