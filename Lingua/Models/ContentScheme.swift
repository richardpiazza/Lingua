import Foundation
import TranslationCatalog

enum ContentScheme: Hashable {
    case catalog
    case needsReview
    case missingLocales
    case project(Project.ID)
}

extension ContentScheme {
    static let specialCases: [ContentScheme] = [
        .catalog,
        .needsReview,
        .missingLocales,
    ]
}

extension ContentScheme: CustomStringConvertible {
    var description: String {
        switch self {
        case .catalog:
            "All Expressions"
        case .needsReview:
            "Needs Review"
        case .missingLocales:
            "Missing Translations"
        case .project(let id):
            "Project \(id)"
        }
    }
}
