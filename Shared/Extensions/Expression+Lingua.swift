import TranslationCatalog

extension Expression {
    var defaultTranslation: Translation? {
        translations.first(where: { $0.languageCode == defaultLanguage })
    }
    
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
