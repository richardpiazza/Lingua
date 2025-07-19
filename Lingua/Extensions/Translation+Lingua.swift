import Foundation
import TranslationCatalog

extension TranslationCatalog.Translation {
    nonisolated var languageName: String {
        Locale.current.localizedString(forLanguageCode: language.identifier) ?? language.identifier
    }
}

extension TranslationCatalog.Translation {
    static let add_en_US = TranslationCatalog.Translation(
        id: .translationAdd_en_US,
        expressionId: .expressionAdd,
        language: .english,
        region: .unitedStates,
        value: "Add",
    )

    static let add_es_ES = TranslationCatalog.Translation(
        id: .translationAdd_es_ES,
        expressionId: .expressionAdd,
        language: .spanish,
        region: .spain,
        value: "Añadir",
    )

    static let add_it_IT = TranslationCatalog.Translation(
        id: .translationAdd_it_IT,
        expressionId: .expressionAdd,
        language: .italian,
        region: .italy,
        value: "Add",
    )

    static let update_en_US = TranslationCatalog.Translation(
        id: .translationRemove_en_US,
        expressionId: .expressionUpdate,
        language: .english,
        region: .unitedStates,
        value: "Update",
    )

    static let update_es_ES = TranslationCatalog.Translation(
        id: .translationRemove_es_ES,
        expressionId: .expressionUpdate,
        language: .spanish,
        region: .spain,
        value: "Actualizar",
    )

    static let update_it_IT = TranslationCatalog.Translation(
        id: .translationRemove_it_IT,
        expressionId: .expressionUpdate,
        language: .italian,
        region: .italy,
        value: "Aggiornamento",
    )

    static let remove_en_US = TranslationCatalog.Translation(
        id: .translationRemove_en_US,
        expressionId: .expressionRemove,
        language: .english,
        region: .unitedStates,
        value: "Remove",
    )

    static let remove_es_ES = TranslationCatalog.Translation(
        id: .translationRemove_es_ES,
        expressionId: .expressionRemove,
        language: .spanish,
        region: .spain,
        value: "Quitar",
    )

    static let remove_it_IT = TranslationCatalog.Translation(
        id: .translationRemove_it_IT,
        expressionId: .expressionRemove,
        language: .italian,
        region: .italy,
        value: "Rimuovere",
    )

    static let settings_en_US = TranslationCatalog.Translation(
        id: .translationSettings_en_US,
        expressionId: .expressionSettings,
        language: .english,
        region: .unitedStates,
        value: "Settings",
    )

    static let settings_es_ES = TranslationCatalog.Translation(
        id: .translationSettings_es_ES,
        expressionId: .expressionSettings,
        language: .spanish,
        region: .spain,
        value: "Configuración",
    )

    static let settings_it_IT = TranslationCatalog.Translation(
        id: .translationSettings_it_IT,
        expressionId: .expressionSettings,
        language: .italian,
        region: .italy,
        value: "Configurazione",
    )
}
