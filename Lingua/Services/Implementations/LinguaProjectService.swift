import AsyncPlus
import Foundation
import Combine
import LocaleSupport
import TranslationCatalog
import Infuse
import Logging

class LinguaProjectService: ProjectService {
    
    @Resource private var logger: Logger
    @Resource private var catalogService: CatalogService
    
    private var subject = CurrentValueAsyncSubject<[Project]>([])
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
                Task {
                    await self?.subject.yield(projects)
                }
            })
    }
    
    func projects() async -> AsyncStream<[Project]> {
        await subject.sink()
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
        
        Task {
            var values = await subject.value
            values.append(project)
            await subject.yield(values)
        }
        
        return project
    }
    
    func deleteProject(_ id: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.deleteProject(id)
        
        Task {
            var values = await subject.value
            if let index = values.firstIndex(where: { $0.id == id }) {
                values.remove(at: index)
                await subject.yield(values)
            }
        }
    }
    
    func linkExpression(_ id: TranslationCatalog.Expression.ID, to project: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.updateProject(project, action: GenericProjectUpdate.linkExpression(id))
        
        guard let expression = try? catalog.expression(id) else {
            return
        }
        
        Task {
            var values = await subject.value
            if let index = values.firstIndex(where: { $0.id == project }) {
                let updated = Project(
                    id: values[index].id,
                    name: values[index].name,
                    expressions: values[index].expressions + [expression]
                )
                values[index] = updated
                await subject.yield(values)
            }
        }
    }
    
    func unlinkExpression(_ id: TranslationCatalog.Expression.ID, from project: Project.ID) throws {
        guard let catalog = catalogService.catalog else {
            throw LinguaError.catalog
        }
        
        try catalog.updateProject(project, action: GenericProjectUpdate.unlinkExpression(id))
        
        Task {
            var values = await subject.value
            if let index = values.firstIndex(where: { $0.id == project }) {
                var expressions = values[index].expressions
                expressions.removeAll(where: { $0.id == id })
                
                let updated = Project(
                    id: values[index].id,
                    name: values[index].name,
                    expressions: expressions
                )
                values[index] = updated
                await subject.yield(values)
            }
        }
    }
}
