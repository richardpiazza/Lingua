import SwiftUI
import TranslationCatalog

struct ProjectNavigator: View {
    
    class ViewModel: ObservableObject {
        let persistenceManager: PersistenceManager = .shared
        
        @Published var projects: [Project] = []
        
        init() {
            projects = (try? persistenceManager.catalog.projects()) ?? []
        }
        
        func createProject() {
        }
        
        func export() {
        }
    }
    
    @Binding var contentMode: ContentMode?
    @StateObject var viewModel: ViewModel = .init()
    
    var body: some View {
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
        .toolbar {
            ToolbarItemGroup {
                Button(action: viewModel.createProject, label: {
                    Image(systemName: "folder.badge.plus")
                })
                
                Button(action: viewModel.export, label: {
                    Image(systemName: "square.and.arrow.up")
                })
            }
        }
    }
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ProjectNavigator(contentMode: .constant(.catalog))
    }
}
