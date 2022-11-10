import SwiftUI
import Combine
import TranslationCatalog

struct ProjectNavigator: View {
    
    class ViewModel: ObservableObject {
        
        struct EmptyProjectName: Error {}
        
        @Dependency private var projectService: ProjectService
        
        @Published var projects: [Project] = []
        
        
        private var projectSubscription: AnyCancellable?
        
        init() {
            projectSubscription = projectService
                .$projects
                .assign(to: \.projects, on: self)
        }
        
        func createNewProject(named: String, completion: @escaping (Result<Project, Error>) -> Void) {
            guard !named.isEmpty else {
                completion(.failure(EmptyProjectName()))
                return
            }
            
            projectService.createProject(named, resultHandler: completion)
        }
    }
    
    @Binding var contentMode: ContentMode?
    @StateObject var viewModel: ViewModel = .init()
    @State private var newProjectName: String = ""
    @State private var newProjectError: Error?
    @State private var showExport: Bool = false
    @State private var showCreateProject: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Catalog")) {
                    NavigationLink(
                        destination: ExpressionNavigator(viewModel: .init(contentMode: contentMode)),
                        tag: ContentMode.catalog,
                        selection: $contentMode,
                        label: {
                            Text("All Expressions")
                        })
                }
                
                Section(header: Text("Projects")) {
                    ForEach(viewModel.projects) { project in
                        NavigationLink(
                            destination: ExpressionNavigator(viewModel: .init(contentMode: contentMode)),
                            tag: ContentMode.project(project.id),
                            selection: $contentMode,
                            label: {
                                Text(project.name)
                            })
                    }
                }
            }
            .listStyle(SidebarListStyle())
            
            Divider()
            
            HStack {
                Button {
                    showCreateProject.toggle()
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .symbolRenderingMode(.multicolor)
                }
                .sheet(isPresented: $showCreateProject) {
                    CreateProjectView(
                        name: $newProjectName,
                        error: $newProjectError,
                        cancelAction: {
                            showCreateProject.toggle()
                            newProjectName = ""
                            newProjectError = nil
                        },
                        createAction: {
                            viewModel.createNewProject(named: newProjectName) { result in
                                switch result {
                                case .success(let project):
                                    showCreateProject.toggle()
                                    newProjectName = ""
                                    newProjectError = nil
                                    contentMode = .project(project.id)
                                case .failure(let error):
                                    newProjectError = error
                                }
                            }
                        }
                    )
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "folder.badge.minus")
                        .symbolRenderingMode(.multicolor)
                }
                .disabled(contentMode?.isProject == false)
                
                Spacer()
                
                Button {
                    showExport.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $showExport) {
                    Button {
                        showExport.toggle()
                    } label: {
                        Text("Hide")
                    }
                }
            }
            .padding()
        }
    }
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ProjectNavigator(contentMode: .constant(.catalog))
    }
}
