import Foundation
import TranslationCatalog

nonisolated struct ExpressionComparator: SortComparator {
    var order: SortOrder = .forward

    func compare(_ lhs: TranslationCatalog.Expression, _ rhs: TranslationCatalog.Expression) -> ComparisonResult {
        switch order {
        case .forward:
            switch (lhs.name.isEmpty, rhs.name.isEmpty) {
            case (true, true):
                lhs.key.localizedCaseInsensitiveCompare(rhs.key)
            case (true, false):
                lhs.key.localizedCaseInsensitiveCompare(rhs.name)
            case (false, true):
                lhs.name.localizedCaseInsensitiveCompare(rhs.key)
            case (false, false):
                lhs.name.localizedCaseInsensitiveCompare(rhs.name)
            }
        case .reverse:
            switch (rhs.name.isEmpty, lhs.name.isEmpty) {
            case (true, true):
                rhs.key.localizedCaseInsensitiveCompare(lhs.key)
            case (true, false):
                rhs.key.localizedCaseInsensitiveCompare(lhs.name)
            case (false, true):
                rhs.name.localizedCaseInsensitiveCompare(lhs.key)
            case (false, false):
                rhs.name.localizedCaseInsensitiveCompare(lhs.name)
            }
        }
    }
}
