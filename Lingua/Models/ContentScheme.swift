import Foundation
import TranslationCatalog

enum ContentScheme: Hashable {
    case catalog
    case project(Project.ID)
}
