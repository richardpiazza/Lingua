import SwiftUI
import TranslationCatalog

struct CreateProjectView: View {
    
    class ViewModel: ObservableObject {
        @Dependency private var projectService: ProjectService
        
        @Published var name: String = ""
        
        init(name: String = "") {
            self.name = name
        }
        
        func createProject(resultHandler: @escaping (Result<Project, Error>) -> Void) {
            projectService.createProject(name, resultHandler: resultHandler)
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @Binding var show: Bool
    @Binding var contentMode: ContentMode?
    @State private var error: Error?
    
    init(
        viewModel: ViewModel = .init(),
        show: Binding<Bool> = .constant(true),
        contentMode: Binding<ContentMode?>  = .constant(nil),
        error: Error? = nil
    ) {
        self.viewModel = viewModel
        _show = show
        _contentMode = contentMode
        self.error = error
    }
    
    var body: some View {
        VStack {
            Text("Create Project")
                .font(.headline)
            
            TextField("Name", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = self.error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack {
                Button(action: {
                    show.toggle()
                }, label: {
                    Text("Cancel")
                })
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    viewModel.createProject() { result in
                        switch result {
                        case .failure(let error):
                            self.error = error
                        case .success(let project):
                            contentMode = .project(project.id)
                            show.toggle()
                        }
                    }
                }, label: {
                    Text("Create")
                })
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: 270.0, minHeight: 270)
    }
}

struct CreateProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProjectView()
    }
}
