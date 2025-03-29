import Combine
import Foundation
import TranslationCatalog

class EmulatedProjectService: ProjectService {
    
    let projectsSubject = CurrentValueSubject<[TranslationCatalog.Project], Never>([])
    
    var projectsPublisher: AnyPublisher<[TranslationCatalog.Project], Never> { projectsSubject.eraseToAnyPublisher() }
    
    init(projects: [TranslationCatalog.Project] = []) {
        projectsSubject.send(projects)
    }
    
    func createProject(_ name: String) throws -> TranslationCatalog.Project {
        throw CocoaError(.featureUnsupported)
    }
    
    func deleteProject(_ id: TranslationCatalog.Project.ID) throws {
        throw CocoaError(.featureUnsupported)
    }
    
    func linkExpression(_ id: TranslationCatalog.Expression.ID, to project: TranslationCatalog.Project.ID) throws {
        throw CocoaError(.featureUnsupported)
    }
    
    func unlinkExpression(_ id: TranslationCatalog.Expression.ID, from project: TranslationCatalog.Project.ID) throws {
        throw CocoaError(.featureUnsupported)
    }
}
