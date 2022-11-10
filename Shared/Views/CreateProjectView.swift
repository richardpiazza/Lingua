import SwiftUI
import TranslationCatalog

struct CreateProjectView: View {
    
    @Binding var name: String
    @Binding var error: Error?
    var cancelAction: () -> Void
    var createAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Create Project")
                .font(.headline)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = self.error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(spacing: 16) {
                Button(role: .cancel) {
                    cancelAction()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    createAction()
                } label: {
                    Text("Create")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding()
        .frame(idealWidth: 270.0, maxWidth: 270.0, idealHeight: 270)
    }
}

struct CreateProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProjectView(
            name: .constant("Project Name"),
            error: .constant(nil),
            cancelAction: {},
            createAction: {}
        )
    }
}
