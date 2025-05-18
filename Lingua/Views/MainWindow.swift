import Infuse
import SwiftUI
import TranslationCatalog

struct MainWindow: View {

    var catalogService: CatalogService?
    var projectService: ProjectService?
    
    @State private var requireCatalog: Bool = false
    @State private var contentScheme: ContentScheme = .catalog
    @State private var projects: [Project] = []
    @State private var expression: TranslationCatalog.Expression?
    
    private var resolvedCatalogService: CatalogService {
        if let catalogService {
            catalogService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    private var resolvedProjectService: ProjectService {
        if let projectService {
            projectService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    var body: some View {
        NavigationSplitView {
            #if os(macOS)
            MacOSSidebarView(
                contentScheme: $contentScheme,
                projects: projects
            )
            .navigationSplitViewColumnWidth(ideal: 245)
            #else
            SidebarView(
                contentScheme: $contentScheme,
                projects: projects
            )
            .navigationSplitViewColumnWidth(ideal: 245)
            #endif
        } content: {
            ExpressionListView(
                selectedExpression: $expression,
                contentScheme: contentScheme
            )
            .navigationSplitViewColumnWidth(ideal: 305)
        } detail: {
            if let expression {
                ExpressionView(
                    expression: expression,
                    contentScheme: contentScheme,
                    projects: projects
                ) {
                    self.expression = nil
                }
            } else {
                ContentUnavailableView(
                    "",
                    systemImage: "rectangle.and.text.magnifyingglass",
                    description: Text("Select an Expression")
                )
            }
        }
        .sheet(isPresented: $requireCatalog) {
            StorageSelectorView()
        }
        .onReceive(resolvedCatalogService.requireCatalogPublisher) { value in
            requireCatalog = value
        }
        .task {
            let stream = await resolvedProjectService.projects()
            for await values in stream {
                projects = values
            }
        }
    }
}

#Preview {
    MainWindow()
        .frame(width: 800)
}
