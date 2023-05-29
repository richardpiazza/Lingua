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
    
    func createProject(_ name: String) throws -> Project {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        let query = GenericProjectQuery.named(name)
        if let _ = try? catalog.project(matching: query) {
            throw CatalogError.badQuery(query)
        }
        
        let project = Project(uuid: UUID(), name: name)
        try catalog.createProject(project)
        projects.append(project)
        return project
    }
    
    func deleteProject(_ id: Project.ID) throws {
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
    
    func linkExpression(_ id: Expression.ID, to project: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        do {
            try catalog.updateProject(project, action: GenericProjectUpdate.linkExpression(id))
            guard let index = projects.firstIndex(where: { $0.id == project}) else {
                return
            }
            
            guard let expression = try? catalog.expression(id) else {
                return
            }
            
            projects[index].expressions.append(expression)
        } catch {
            throw error
        }
    }
    
    func unlinkExpression(_ id: Expression.ID, from project: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        do {
            try catalog.updateProject(project, action: GenericProjectUpdate.unlinkExpression(id))
            guard let index = projects.firstIndex(where: { $0.id == project }) else {
                return
            }
            
            projects[index].expressions.removeAll(where: { $0.id == id })
        } catch {
            throw error
        }
    }
}
