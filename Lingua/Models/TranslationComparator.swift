import Foundation
import TranslationCatalog

struct TranslationComparator: SortComparator {
    var order: SortOrder = .forward
    
    func compare(_ lhs: TranslationCatalog.Translation, _ rhs: TranslationCatalog.Translation) -> ComparisonResult {
        switch order {
        case .forward:
            lhs.languageName.localizedCaseInsensitiveCompare(rhs.languageName)
        case .reverse:
            rhs.languageName.localizedCaseInsensitiveCompare(lhs.languageName)
        }
    }
}
