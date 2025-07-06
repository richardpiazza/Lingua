import Foundation
import TranslationCatalog

nonisolated struct ProjectComparator: SortComparator {
    var order: SortOrder = .forward
    
    func compare(_ lhs: TranslationCatalog.Project, _ rhs: TranslationCatalog.Project) -> ComparisonResult {
        switch order {
        case .forward:
            lhs.name.localizedCaseInsensitiveCompare(rhs.name)
        case .reverse:
            rhs.name.localizedCaseInsensitiveCompare(lhs.name)
        }
    }
}
