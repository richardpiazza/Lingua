import TranslationCatalog

extension TranslationState {
    var name: String {
        switch self {
        case .needsReview: "Needs Review"
        case .new: "New"
        case .translated: "Translated"
        default: rawValue
        }
    }
}
