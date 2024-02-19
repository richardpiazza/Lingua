import Foundation
import Combine
import LocaleSupport
import TranslationCatalog
import Infuse
import Logging

class LinguaProjectService: ProjectService {
    
    struct InvalidCatalog: Error {}
    
    var projects: [Project] { projectsSubject.value }
    var projectsPublisher: AnyPublisher<[Project], Never> { projectsSubject.eraseToAnyPublisher() }
    
    @Resource private var logger: Logger
    @Resource private var catalogService: CatalogService
    
    private var projectsSubject = CurrentValueSubject<[Project], Never>([])
    private var projectsSubscription: AnyCancellable?
    
    init() {
        postInit()
    }
    
    private func postInit() {
        projectsSubscription = catalogService.catalogPublisher
            .compactMap { $0 }
            .map { (try? $0.projects()) ?? [] }
            .map { projects in
                projects.sorted(by: { $0.name < $1.name })
            }
            .sink(receiveValue: { [weak self] projects in
                self?.projectsSubject.value = projects
            })
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
        projectsSubject.value.append(project)
        return project
    }
    
    func deleteProject(_ id: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw InvalidCatalog()
        }
        
        do {
            try catalog.deleteProject(id)
        } catch {
            throw logger.error("Failed to Delete Project.", error: LinguaError.projectDelete(error))
        }
        
        projectsSubject.value.removeAll(where: { $0.id == id })
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
            
            projectsSubject.value[index].expressions.append(expression)
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
            
            projectsSubject.value[index].expressions.removeAll(where: { $0.id == id })
        } catch {
            throw error
        }
    }
}
