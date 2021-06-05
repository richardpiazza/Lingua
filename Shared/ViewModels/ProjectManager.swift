import Foundation
import TranslationCatalog

class ProjectManager: ObservableObject {
    
    static let shared: ProjectManager = .init(persistenceManager: .shared)
    
    private let persistenceManager: PersistenceManager
    
    @Published var projects: [Project] = []
    
    private init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
        
        projects = (try? persistenceManager.catalog.projects()) ?? []
    }
}

extension ProjectManager {
    func createProject() {
    }
    
    func export() {
    }
}
