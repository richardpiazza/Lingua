import Foundation
import Combine
import LocaleSupport
import TranslationCatalog
import CodeQuickKit
import Logging

class ProjectService {
    
    struct InvalidCatalog: Error {}
    
    @Dependency private var logger: Logger
    @Dependency private var catalogService: CatalogService
    
    @Published var projects: [Project] = []
    
    init() {
        postInit()
    }
    
    private func postInit() {
        catalogService.$catalog
            .compactMap { $0 }
            .map { (try? $0.projects()) ?? [] }
            .map { projects in
                projects.sorted(by: { $0.name < $1.name })
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$projects)
    }
    
    func createProject(_ name: String, resultHandler: @escaping (Result<Project, Swift.Error>) -> Void) {
        guard let catalog = catalogService.catalog else {
            resultHandler(.failure(InvalidCatalog()))
            return
        }
        
        let query = GenericProjectQuery.named(name)
        if let _ = try? catalog.project(matching: query) {
            resultHandler(.failure(CatalogError.badQuery(query)))
            return
        }
        
        let project = Project(uuid: UUID(), name: name)
        do {
            try catalog.createProject(project)
            projects.append(project)
            resultHandler(.success(project))
        } catch {
            resultHandler(.failure(error))
        }
    }
    
    func deleteProject(_ id: Project.ID) async throws {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        do {
            try catalog.deleteProject(id)
        } catch {
            logger.error("Failed to Delete Project.", error: error)
            throw error
        }
        
        projects.removeAll(where: { $0.id == id })
    }
}
