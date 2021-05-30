import SwiftUI
import TranslationCatalog

struct ProjectNavigator: View {
    
    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var projectManager: ProjectManager
    
    var body: some View {
        List {
            Section(header: Text("Catalog")) {
                NavigationLink(
                    destination: ExpressionNavigator(),
                    tag: StateManager.ContentMode.catalog,
                    selection: $stateManager.contentMode,
                    label: {
                        Text("All Expressions")
                    })
            }
            
            Section(header: Text("Projects")) {
                ForEach(projectManager.projects) { project in
                    NavigationLink(
                        destination: ExpressionNavigator(),
                        tag: StateManager.ContentMode.project(project.id),
                        selection: $stateManager.contentMode,
                        label: {
                            Text(project.name)
                        })
                }
            }
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItemGroup {
                Button(action: projectManager.createProject, label: {
                    Image(systemName: "folder.badge.plus")
                })
                
                Button(action: projectManager.export, label: {
                    Image(systemName: "square.and.arrow.up")
                })
            }
        }
    }
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ProjectNavigator()
            .environmentObject(StateManager.shared)
            .environmentObject(PersistenceManager.shared)
            .environmentObject(ProjectManager.shared)
            .environmentObject(ExpressionManager.shared)
            .environmentObject(TranslationManager.shared)
    }
}
