import Foundation
import TranslationCatalog

protocol ProjectService {
    func projects() async -> AsyncStream<[Project]>
    func createProject(_ name: String) throws -> Project
    func deleteProject(_ id: Project.ID) throws
    func linkExpression(_ id: TranslationCatalog.Expression.ID, to project: Project.ID) throws
    func unlinkExpression(_ id: TranslationCatalog.Expression.ID, from project: Project.ID) throws
}
