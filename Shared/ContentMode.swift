import Foundation
import TranslationCatalog

enum ContentMode: Hashable {
    case catalog
    case project(Project.ID)
    case search(String)
    
    var isProject: Bool {
        switch self {
        case .project: return true
        default: return false
        }
    }
}
