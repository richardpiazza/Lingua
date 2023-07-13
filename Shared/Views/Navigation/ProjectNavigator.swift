import SwiftUI
import TranslationCatalog

struct ProjectNavigator: View {
    
    @StateObject var viewModel: ProjectNavigatorViewModel = .init()
    
    @State private var newProjectName: String = ""
    @State private var newProjectError: Error?
    @State private var showCreateProject: Bool = false
    @State private var confirmDelete: Bool = false
    
    var body: some View {
        List(selection: $viewModel.contentMode) {
            Section("Catalog") {
                NavigationLink("All Expressions", value: ContentMode.catalog)
                    .font(.headline)
            }
            
            Section("Projects") {
                ForEach(viewModel.projects) { project in
                    HStack {
                        NavigationLink(project.name, value: ContentMode.project(project.id))
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            confirmDelete = true
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .alert("Delete Project?", isPresented: $confirmDelete) {
                            Button("Cancel", role: .cancel) {}
                            Button("Remove", role: .destructive) {
                                do {
                                    try viewModel.deleteProject(project.id)
                                } catch {
                                }
                            }
                        } message: {
                            Text("Are you sure you want to delete project '\(project.name)' from the catalog? Expressions and Translations will not be affected.")
                        }
                    }
                }
                
                Button {
                    showCreateProject = true
                } label: {
                    HStack {
                        Text("Create Project")
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle")
                    }
                }
                .buttonStyle(.borderless)
                .sheet(isPresented: $showCreateProject) {
                    CreateProjectView(
                        name: $newProjectName,
                        error: $newProjectError,
                        cancelAction: {
                            showCreateProject = false
                            newProjectName = ""
                            newProjectError = nil
                        },
                        createAction: {
                            do {
                                let project = try viewModel.createNewProject(named: newProjectName)
                                showCreateProject = false
                                newProjectName = ""
                                newProjectError = nil
                                viewModel.contentMode = .project(project.id)
                            } catch {
                                newProjectError = error
                            }
                        }
                    )
                }
            }
            
            Section("Features") {
            }
        }
        .listStyle(SidebarListStyle())
        .navigationDestination(for: ContentMode.self) { contentMode in
            ExpressionNavigator()
        }
    }        
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectNavigator()
        }
    }
}
