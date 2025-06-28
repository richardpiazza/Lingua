import Foundation
@preconcurrency import TranslationCatalog

nonisolated struct TranslationComparator: SortComparator {
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
