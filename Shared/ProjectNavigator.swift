import SwiftUI
import TranslationCatalog

struct ProjectNavigator: View {
    
    class ViewModel: ObservableObject {
        let catalog: Catalog
        @Published var projects: [Project]
        
        init(catalog: Catalog) {
            self.catalog = catalog
            projects = (try? catalog.projects()) ?? []
        }
    }
    
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            Section(header: Text("Catalog")) {
                NavigationLink(
                    destination: ExpressionNavigator(viewModel: .init(catalog: viewModel.catalog, contentMode: .catalog)),
                    tag: AppEnvironment.ContentMode.catalog,
                    selection: $appEnvironment.contentMode,
                    label: {
                        Text("All Expressions")
                    })
            }
            
            Section(header: Text("Projects")) {
                ForEach(viewModel.projects) { project in
                    NavigationLink(
                        destination: ExpressionNavigator(viewModel: .init(catalog: viewModel.catalog, contentMode: .project(project.id))),
                        tag: AppEnvironment.ContentMode.project(project.id),
                        selection: $appEnvironment.contentMode,
                        label: {
                            Text(project.name)
                        })
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct ProjectNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ProjectNavigator(viewModel: .init(catalog: LocalCatalog.default))
            .environmentObject(AppEnvironment())
    }
}
