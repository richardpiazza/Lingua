import Foundation
import TranslationCatalog

enum ContentScheme: Hashable {
    case catalog
    case project(Project.ID)
}

extension ContentScheme: CustomStringConvertible {
    var description: String {
        switch self {
        case .catalog:
            "Catalog"
        case .project(let id):
            "Project \(id)"
        }
    }
}
