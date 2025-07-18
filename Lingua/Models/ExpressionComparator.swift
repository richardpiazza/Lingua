import Foundation
import TranslationCatalog

nonisolated struct ExpressionComparator: SortComparator {
    var order: SortOrder = .forward

    func compare(_ lhs: TranslationCatalog.Expression, _ rhs: TranslationCatalog.Expression) -> ComparisonResult {
        switch order {
        case .forward:
            lhs.name.localizedCaseInsensitiveCompare(rhs.name)
        case .reverse:
            rhs.name.localizedCaseInsensitiveCompare(lhs.name)
        }
    }
}
