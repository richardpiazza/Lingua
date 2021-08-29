import Foundation
import Combine
import LocaleSupport
import TranslationCatalog

class ProjectService {
    
    enum Error: Swift.Error {
        case existingProject(Project)
    }
    
    @Dependency private var persistence: PersistenceManager
    
    @Published var projects: [Project] = []
    
    init() {
        if let catalogProjects = try? persistence.catalog.projects() {
            projects = catalogProjects.sorted(by: { $0.name < $1.name })
        }
    }
    
    func createProject(_ name: String, resultHandler: @escaping (Result<Project, Swift.Error>) -> Void) {
        if let existing = try? persistence.catalog.project(matching: GenericProjectQuery.named(name)) {
            resultHandler(.failure(Error.existingProject(existing)))
            return
        }
        
        let project = Project(uuid: UUID(), name: name)
        do {
            try persistence.catalog.createProject(project)
        } catch {
            resultHandler(.failure(error))
            return
        }
        
        resultHandler(.success(project))
    }
}
