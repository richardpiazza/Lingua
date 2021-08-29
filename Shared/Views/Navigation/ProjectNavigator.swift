import SwiftUI
import Combine
import TranslationCatalog

struct ProjectNavigator: View {
    
    class ViewModel: ObservableObject {
        @Dependency private var projectService: ProjectService
        
        @Published var projects: [Project] = []
        
        private var projectSubscription: AnyCancellable?
        
        init() {
            projectSubscription = projectService
                .$projects
                .assign(to: \.projects, on: self)
        }
    }
    
    @Binding var contentMode: ContentMode?
    @StateObject var viewModel: ViewModel = .init()
    @State private var showCreateProject: Bool = false
    @State private var showExport: Bool = false
    
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
                Button(action: {
                    showCreateProject.toggle()
                }, label: {
                    Image(systemName: "folder.badge.plus")
                })
                    .sheet(isPresented: $showCreateProject) {
                        Button {
                            showCreateProject.toggle()
                        } label: {
                            CreateProjectView(show: $showCreateProject, contentMode: $contentMode)
                        }

                    }
                
                Button(action: {
                    showExport.toggle()
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                    .sheet(isPresented: $showExport) {
                        Button {
                            showExport.toggle()
                        } label: {
                            Text("Hide")
                        }

                    }
            }
        }
    }
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ProjectNavigator(contentMode: .constant(.catalog))
    }
}
