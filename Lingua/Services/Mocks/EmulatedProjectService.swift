import AsyncPlus
import Foundation
import TranslationCatalog

class EmulatedProjectService: ProjectService {
    
    private let subject = CurrentValueAsyncSubject<[Project]>([])
    
    init(projects: [TranslationCatalog.Project] = []) {
        Task {
            await subject.yield(projects)
        }
    }
    
    func projects() async -> AsyncStream<[Project]> {
        await subject.sink()
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
