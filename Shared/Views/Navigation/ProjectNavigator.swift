import SwiftUI
import TranslationCatalog

struct ProjectNavigator: View {
    
    @StateObject var viewModel: ProjectNavigatorViewModel = .init()
    
    @State private var newProjectName: String = ""
    @State private var newProjectError: Error?
    @State private var showExport: Bool = false
    @State private var showCreateProject: Bool = false
    @State private var confirmDelete: Bool = false
    
    var body: some View {
        List(selection: $viewModel.contentMode) {
            Section("Catalog") {
                NavigationLink("All Expressions", value: ContentMode.catalog)
            }
            
            Section("Projects") {
                ForEach(viewModel.projects) { project in
                    NavigationLink(project.name, value: ContentMode.project(project.id))
                }
            }
            
            Section("Features") {
            }
        }
        .listStyle(SidebarListStyle())
        .navigationDestination(for: ContentMode.self) { contentMode in
            ExpressionNavigator()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading) {
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
                                do {
                                    let project = try viewModel.createNewProject(named: newProjectName)
                                    showCreateProject.toggle()
                                    newProjectName = ""
                                    newProjectError = nil
                                    viewModel.contentMode = .project(project.id)
                                } catch {
                                    newProjectError = error
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
                            do {
                                try viewModel.deleteCurrentProject()
                            } catch {
                            }
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
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectNavigator()
        }
    }
}
