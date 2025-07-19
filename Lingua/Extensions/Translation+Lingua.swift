import Foundation
import LocaleSupport
import TranslationCatalog

extension TranslationCatalog.Translation {
    nonisolated var locale: Locale {
        if let region = regionCode {
            Locale(identifier: "\(languageCode.rawValue)_\(region.rawValue)")
        } else {
            Locale(identifier: languageCode.rawValue)
        }
    }

    nonisolated var languageName: String {
        Locale.current.localizedString(forLanguageCode: languageCode.rawValue) ?? locale.identifier
    }
}

extension TranslationCatalog.Translation {
    static let add_en_US = TranslationCatalog.Translation(
        id: .translationAdd_en_US,
        expressionId: .expressionAdd,
        languageCode: .en,
        regionCode: .US,
        value: "Add",
    )

    static let add_es_ES = TranslationCatalog.Translation(
        id: .translationAdd_es_ES,
        expressionId: .expressionAdd,
        languageCode: .es,
        regionCode: .ES,
        value: "Añadir",
    )

    static let add_it_IT = TranslationCatalog.Translation(
        id: .translationAdd_it_IT,
        expressionId: .expressionAdd,
        languageCode: .it,
        regionCode: .IT,
        value: "Add",
    )

    static let update_en_US = TranslationCatalog.Translation(
        id: .translationRemove_en_US,
        expressionId: .expressionUpdate,
        languageCode: .en,
        regionCode: .US,
        value: "Update",
    )

    static let update_es_ES = TranslationCatalog.Translation(
        id: .translationRemove_es_ES,
        expressionId: .expressionUpdate,
        languageCode: .es,
        regionCode: .ES,
        value: "Actualizar",
    )

    static let update_it_IT = TranslationCatalog.Translation(
        id: .translationRemove_it_IT,
        expressionId: .expressionUpdate,
        languageCode: .it,
        regionCode: .IT,
        value: "Aggiornamento",
    )

    static let remove_en_US = TranslationCatalog.Translation(
        id: .translationRemove_en_US,
        expressionId: .expressionRemove,
        languageCode: .en,
        regionCode: .US,
        value: "Remove",
    )

    static let remove_es_ES = TranslationCatalog.Translation(
        id: .translationRemove_es_ES,
        expressionId: .expressionRemove,
        languageCode: .es,
        regionCode: .ES,
        value: "Quitar",
    )

    static let remove_it_IT = TranslationCatalog.Translation(
        id: .translationRemove_it_IT,
        expressionId: .expressionRemove,
        languageCode: .it,
        regionCode: .IT,
        value: "Rimuovere",
    )

    static let settings_en_US = TranslationCatalog.Translation(
        id: .translationSettings_en_US,
        expressionId: .expressionSettings,
        languageCode: .en,
        regionCode: .US,
        value: "Settings",
    )

    static let settings_es_ES = TranslationCatalog.Translation(
        id: .translationSettings_es_ES,
        expressionId: .expressionSettings,
        languageCode: .es,
        regionCode: .ES,
        value: "Configuración",
    )

    static let settings_it_IT = TranslationCatalog.Translation(
        id: .translationSettings_it_IT,
        expressionId: .expressionSettings,
        languageCode: .it,
        regionCode: .IT,
        value: "Configurazione",
    )
}
