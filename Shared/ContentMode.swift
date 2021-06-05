import Foundation
import TranslationCatalog

enum ContentMode: Hashable {
    case catalog
    case project(Project.ID)
    case search(String)
}
