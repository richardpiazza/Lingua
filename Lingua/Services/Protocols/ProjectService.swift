import Foundation
import Combine
import TranslationCatalog

protocol ProjectService {
    var projects: [Project] { get }
    var projectsPublisher: AnyPublisher<[Project], Never> { get }
    
    func createProject(_ name: String) throws -> Project
    func deleteProject(_ id: Project.ID) throws
    func linkExpression(_ id: Expression.ID, to project: Project.ID) throws
    func unlinkExpression(_ id: Expression.ID, from project: Project.ID) throws
}
