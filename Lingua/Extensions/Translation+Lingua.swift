import Foundation
import LocaleSupport
import TranslationCatalog

extension TranslationCatalog.Translation {
    var locale: Locale {
        if let region = regionCode {
            return Locale(identifier: "\(languageCode.rawValue)_\(region.rawValue)")
        } else {
            return Locale(identifier: languageCode.rawValue)
        }
    }
    
    var languageName: String {
        Locale.current.localizedString(forLanguageCode: languageCode.rawValue) ?? locale.identifier
    }
}
