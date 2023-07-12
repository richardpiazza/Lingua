import TranslationCatalog

extension Expression {
    var defaultTranslation: Translation? {
        translations.first(where: { $0.languageCode == defaultLanguage })
    }
}
