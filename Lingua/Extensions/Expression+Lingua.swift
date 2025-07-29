import Foundation
import TranslationCatalog

extension TranslationCatalog.Expression {
    func matches(_ query: String) -> Bool {
        if name.localizedCaseInsensitiveContains(query) {
            return true
        }
        if key.localizedStandardContains(query) {
            return true
        }
        if let context, context.localizedCaseInsensitiveContains(query) {
            return true
        }
        if let feature, feature.localizedCaseInsensitiveContains(query) {
            return true
        }

        return false
    }
}

extension TranslationCatalog.Expression {
    static let add = TranslationCatalog.Expression(
        id: .expressionAdd,
        key: "BUTTON_ADD",
        value: "Add",
        languageCode: .english,
        name: "Add",
        context: "Create a new item.",
        feature: "General",
        translations: [
            .add_en_US,
            .add_es_ES,
            .add_it_IT,
        ],
    )

    static let update = TranslationCatalog.Expression(
        id: .expressionUpdate,
        key: "BUTTON_UPDATE",
        value: "Update",
        languageCode: .english,
        name: "Update",
        translations: [
            .update_en_US,
            .update_es_ES,
            .update_it_IT,
        ],
    )

    static let remove = TranslationCatalog.Expression(
        id: .expressionRemove,
        key: "BUTTON_REMOVE",
        value: "Remove",
        languageCode: .english,
        name: "Remove",
        translations: [
            .remove_en_US,
            .remove_es_ES,
            .remove_it_IT,
        ],
    )

    static let settings = TranslationCatalog.Expression(
        id: .expressionSettings,
        key: "BUTTON_SETTINGS",
        value: "Settings",
        languageCode: .english,
        name: "Settings",
        translations: [
            .settings_en_US,
            .settings_es_ES,
            .settings_it_IT,
        ],
    )
}
