import SwiftUI
import TranslationCatalog

struct ProjectNavigator: View {
    
    class ViewModel: ObservableObject {
        let appEnvironment: AppEnvironment
        @Published var projects: [Project] = []
        
        init(appEnvironment: AppEnvironment = .default) {
            self.appEnvironment = appEnvironment
            projects = (try? appEnvironment.catalog.projects()) ?? []
        }
        
        func createProject() {
        }
    }
    
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            Section(header: Text("Catalog")) {
                NavigationLink(
                    destination: ExpressionNavigator(viewModel: .init(appEnvironment: appEnvironment)),
                    tag: AppEnvironment.ContentMode.catalog,
                    selection: $appEnvironment.contentMode,
                    label: {
                        Text("All Expressions")
                    })
            }
            
            Section(header: Text("Projects")) {
                ForEach(viewModel.projects) { project in
                    NavigationLink(
                        destination: ExpressionNavigator(viewModel: .init(appEnvironment: appEnvironment)),
                        tag: AppEnvironment.ContentMode.project(project.id),
                        selection: $appEnvironment.contentMode,
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
            }
        }
    }
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ProjectNavigator(viewModel: .init())
            .environmentObject(AppEnvironment.default)
    }
}
