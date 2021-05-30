import Foundation
import TranslationCatalog

extension TranslationCatalog.Translation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(expressionID)
        hasher.combine(languageCode)
        hasher.combine(scriptCode)
        hasher.combine(regionCode)
        hasher.combine(value)
    }
}

extension Expression: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(key)
        hasher.combine(name)
        hasher.combine(defaultLanguage)
        hasher.combine(context)
        hasher.combine(feature)
        hasher.combine(translations)
    }
}

extension Project: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(name)
        hasher.combine(expressions)
    }
}
