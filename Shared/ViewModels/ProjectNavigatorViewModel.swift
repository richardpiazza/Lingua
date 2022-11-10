import SwiftUI
import Combine
import TranslationCatalog

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
    
    func createNewProject(named: String, completion: @escaping (Result<Project, Error>) -> Void) {
        guard !named.isEmpty else {
            completion(.failure(EmptyProjectName()))
            return
        }
        
        projectService.createProject(named, resultHandler: completion)
    }
    
    func deleteCurrentProject(completion: @escaping () -> Void) {
        guard case let .project(id) = contentMode else {
            completion()
            return
        }
        
        Task {
            do {
                try await projectService.deleteProject(id)
                DispatchQueue.main.async { [weak self] in
                    self?.contentMode = .catalog
                    completion()
                }
            } catch {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}
