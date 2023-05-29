import SwiftUI
import Combine
import TranslationCatalog
import CodeQuickKit

class ProjectNavigatorViewModel: ObservableObject {
    
    struct EmptyProjectName: Error {}
    
    @Dependency private var catalogService: CatalogService
    @Dependency private var projectService: ProjectService
    
    @Published var contentMode: ContentMode? {
        didSet {
            catalogService.contentMode = contentMode
        }
    }
    @Published var projects: [Project] = []
    
    init() {
        catalogService.$contentMode
            .receive(on: DispatchQueue.main)
            .assign(to: &$contentMode)
        
        projectService.$projects
            .receive(on: DispatchQueue.main)
            .assign(to: &$projects)
    }
    
    func createNewProject(named: String) throws -> Project {
        guard !named.isEmpty else {
            throw EmptyProjectName()
        }
        
        return try projectService.createProject(named)
    }
    
    @MainActor func deleteCurrentProject() throws {
        guard case let .project(id) = contentMode else {
            return
        }
        
        try projectService.deleteProject(id)
        contentMode = .catalog
    }
}
