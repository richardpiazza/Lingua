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
    
    private var projectSubscription: AnyCancellable?
    
    init() {
        catalogService.$contentMode
            .receive(on: DispatchQueue.main)
            .assign(to: &$contentMode)
        
        projectSubscription = projectService
            .$projects
            .assign(to: \.projects, on: self)
    }
    
    func createNewProject(named: String, completion: @escaping (Result<Project, Error>) -> Void) {
        guard !named.isEmpty else {
            completion(.failure(EmptyProjectName()))
            return
        }
        
        projectService.createProject(named, resultHandler: completion)
    }
}
