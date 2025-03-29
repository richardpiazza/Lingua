import Foundation
import Combine
import LocaleSupport
import TranslationCatalog
import Infuse
import Logging

class LinguaProjectService: ProjectService {
    
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
            throw LinguaError.catalog
        }
        
        let query = GenericProjectQuery.named(name)
        if let _ = try? catalog.project(matching: query) {
            throw CatalogError.badQuery(query)
        }
        
        let project = Project(id: UUID(), name: name)
        try catalog.createProject(project)
        projectsSubject.value.append(project)
        return project
    }
    
    func deleteProject(_ id: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        do {
            try catalog.deleteProject(id)
        } catch {
            throw logger.error("Failed to Delete Project.", error: LinguaError.projectDelete(error))
        }
        
        projectsSubject.value.removeAll(where: { $0.id == id })
    }
    
    func linkExpression(_ id: TranslationCatalog.Expression.ID, to project: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        do {
            try catalog.updateProject(project, action: GenericProjectUpdate.linkExpression(id))
            guard let index = projects.firstIndex(where: { $0.id == project}) else {
                return
            }
            
            guard let expression = try? catalog.expression(id) else {
                return
            }
            
            let project = projectsSubject.value[index]
            let updated = Project(
                id: project.id,
                name: project.name,
                expressions: project.expressions + [expression]
            )
            
            projectsSubject.value[index] = updated
        } catch {
            throw error
        }
    }
    
    func unlinkExpression(_ id: TranslationCatalog.Expression.ID, from project: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        do {
            try catalog.updateProject(project, action: GenericProjectUpdate.unlinkExpression(id))
            guard let index = projects.firstIndex(where: { $0.id == project }) else {
                return
            }
            
            let project = projectsSubject.value[index]
            var expressions = project.expressions
            expressions.removeAll(where: { $0 .id == id })
            
            let updated = Project(
                id: project.id,
                name: project.name,
                expressions: expressions
            )
            
            projectsSubject.value[index] = updated
        } catch {
            throw error
        }
    }
}
