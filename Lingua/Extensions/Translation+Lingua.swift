import Foundation
import TranslationCatalog

extension TranslationCatalog.Translation {
    init(translation: TranslationCatalog.Translation, state: TranslationState) {
        self.init(
            id: translation.id,
            expressionId: translation.expressionId,
            value: translation.value,
            language: translation.language,
            script: translation.script,
            region: translation.region,
            state: state,
        )
    }

    nonisolated var languageName: String {
        if let localizedName = language.localizedName {
            "\(localizedName) (\(language.identifier))"
        } else {
            language.identifier
        }
    }
}

extension TranslationCatalog.Translation {
    static let add_en_US = TranslationCatalog.Translation(
        id: .translationAdd_en_US,
        expressionId: .expressionAdd,
        value: "Add",
        language: .english,
        region: .unitedStates,
        state: .translated,
    )

    static let add_es_ES = TranslationCatalog.Translation(
        id: .translationAdd_es_ES,
        expressionId: .expressionAdd,
        value: "Añadir",
        language: .spanish,
        region: .spain,
        state: .needsReview,
    )

    static let add_it_IT = TranslationCatalog.Translation(
        id: .translationAdd_it_IT,
        expressionId: .expressionAdd,
        value: "Add",
        language: .italian,
        region: .italy,
    )

    static let update_en_US = TranslationCatalog.Translation(
        id: .translationRemove_en_US,
        expressionId: .expressionUpdate,
        value: "Update",
        language: .english,
        region: .unitedStates,
        state: .translated,
    )

    static let update_es_ES = TranslationCatalog.Translation(
        id: .translationRemove_es_ES,
        expressionId: .expressionUpdate,
        value: "Actualizar",
        language: .spanish,
        region: .spain,
        state: .needsReview,
    )

    static let update_it_IT = TranslationCatalog.Translation(
        id: .translationRemove_it_IT,
        expressionId: .expressionUpdate,
        value: "Aggiornamento",
        language: .italian,
        region: .italy,
        state: .needsReview,
    )

    static let remove_en_US = TranslationCatalog.Translation(
        id: .translationRemove_en_US,
        expressionId: .expressionRemove,
        value: "Remove",
        language: .english,
        region: .unitedStates,
        state: .translated,
    )

    static let remove_es_ES = TranslationCatalog.Translation(
        id: .translationRemove_es_ES,
        expressionId: .expressionRemove,
        value: "Quitar",
        language: .spanish,
        region: .spain,
    )

    static let remove_it_IT = TranslationCatalog.Translation(
        id: .translationRemove_it_IT,
        expressionId: .expressionRemove,
        value: "Rimuovere",
        language: .italian,
        region: .italy,
        state: .needsReview,
    )

    static let settings_en_US = TranslationCatalog.Translation(
        id: .translationSettings_en_US,
        expressionId: .expressionSettings,
        value: "Settings",
        language: .english,
        region: .unitedStates,
        state: .translated,
    )

    static let settings_es_ES = TranslationCatalog.Translation(
        id: .translationSettings_es_ES,
        expressionId: .expressionSettings,
        value: "Configuración",
        language: .spanish,
        region: .spain,
    )

    static let settings_it_IT = TranslationCatalog.Translation(
        id: .translationSettings_it_IT,
        expressionId: .expressionSettings,
        value: "Configurazione",
        language: .italian,
        region: .italy,
        state: .needsReview,
    )
}
