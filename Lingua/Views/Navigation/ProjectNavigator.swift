import Infuse
import SwiftUI
import TranslationCatalog

struct ProjectNavigator: View {
    
    private let catalogService: CatalogService
    private let projectService: ProjectService
    
    @State private var contentScheme: ContentScheme = .catalog
    @State private var projects: [Project] = []
    @State private var showCreateProject: Bool = false
    @State private var confirmDelete: Bool = false
    @State private var deleteProject: Project?
    
    init(
        catalogService: CatalogService? = nil,
        projectService: ProjectService? = nil
    ) {
        if let catalogService {
            self.catalogService = catalogService
        } else {
            @Resource var service: CatalogService
            self.catalogService = service
        }
        
        if let projectService {
            self.projectService = projectService
        } else {
            @Resource var service: ProjectService
            self.projectService = service
        }
    }
    
    var body: some View {
        List(selection: $contentScheme) {
            Section("Catalog") {
                NavigationLink {
                    ExpressionNavigator(
                        contentScheme: .catalog
                    )
                } label: {
                    Text("All Expressions")
                        .font(.headline)
                }
                .tag(ContentScheme.catalog)
            }
            
            Section("Projects") {
                ForEach(projects) { project in
                    NavigationLink {
                        ExpressionNavigator(
                            contentScheme: .project(project.id)
                        )
                    } label: {
                        HStack {
                            Text(project.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Button {
                                deleteProject = project
                                confirmDelete = true
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .tag(ContentScheme.project(project.id))
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
                    CreateProjectView { action in
                        showCreateProject = false
                        if case .create(let name) = action {
                            createNewProject(named: name)
                        }
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .onReceive(projectService.projectsPublisher) { value in
            projects = value
        }
        .alert("Delete Project?", isPresented: $confirmDelete, presenting: deleteProject) { project in
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                deleteProject(project.id)
            }
        } message: { project in
            Text("Are you sure you want to delete project '\(project.name)' from the catalog? Expressions and Translations will not be affected.")
        }
    }
    
    private func createNewProject(named name: String) {
        do {
            let project = try projectService.createProject(name)
            contentScheme = .project(project.id)
        } catch {
        }
    }
    
    private func deleteProject(_ id: Project.ID) {
        let resetSelection = contentScheme == .project(id)
        do {
            try projectService.deleteProject(id)
            if resetSelection {
                contentScheme = .catalog
            }
        } catch {
        }
    }
}

#Preview {
    ProjectNavigator(
        catalogService: EmulatedCatalogService(),
        projectService: EmulatedProjectService(
            projects: [
                Project(
                    name: "Example 1"
                )
            ]
        )
    )
    .frame(width: 200)
}
