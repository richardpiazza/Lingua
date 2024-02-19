import SwiftUI
import Combine
import TranslationCatalog
import Infuse

class ProjectNavigatorViewModel: ObservableObject {
    
    struct EmptyProjectName: Error {}
    
    @Resource private var catalogService: CatalogService
    @Resource private var projectService: ProjectService
    
    @Published var contentMode: ContentMode? {
        didSet {
            catalogService.setContentMode(contentMode)
        }
    }
    @Published var projects: [Project] = []
    
    init() {
        catalogService.contentModePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$contentMode)
        
        projectService.projectsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$projects)
    }
    
    func createNewProject(named: String) throws -> Project {
        guard !named.isEmpty else {
            throw EmptyProjectName()
        }
        
        return try projectService.createProject(named)
    }
    
    @MainActor func deleteProject(_ id: Project.ID) throws {
        let resetSelection = contentMode == .project(id)
        try projectService.deleteProject(id)
        if resetSelection {
            contentMode = .catalog
        }
    }
}
