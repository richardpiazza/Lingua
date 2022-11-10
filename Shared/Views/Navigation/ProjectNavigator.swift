import SwiftUI

struct ProjectNavigator: View {
    
    @StateObject var viewModel: ProjectNavigatorViewModel = .init()
    
    @State private var newProjectName: String = ""
    @State private var newProjectError: Error?
    @State private var showExport: Bool = false
    @State private var showCreateProject: Bool = false
    @State private var confirmDelete: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Catalog")) {
                    NavigationLink(
                        destination: ExpressionNavigator(),
                        tag: ContentMode.catalog,
                        selection: $viewModel.contentMode,
                        label: {
                            Text("All Expressions")
                        })
                }
                
                Section(header: Text("Projects")) {
                    ForEach(viewModel.projects) { project in
                        NavigationLink(
                            destination: ExpressionNavigator(),
                            tag: ContentMode.project(project.id),
                            selection: $viewModel.contentMode,
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
                                    viewModel.contentMode = .project(project.id)
                                case .failure(let error):
                                    newProjectError = error
                                }
                            }
                        }
                    )
                }
                
                Button {
                    confirmDelete.toggle()
                } label: {
                    Image(systemName: "folder.badge.minus")
                        .symbolRenderingMode(.multicolor)
                }
                .disabled(viewModel.contentMode?.isProject == false)
                .alert("Delete Project?", isPresented: $confirmDelete) {
                    Button("Cancel", role: .cancel) {}
                    Button("Remove", role: .destructive) {
                        confirmDelete.toggle()
                    }
                } message: {
                    Text("Are you sure you want to delete this project from the catalog? Expressions and Translations will not be affected.")
                }
                
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
        ProjectNavigator()
    }
}
