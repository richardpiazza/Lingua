import Foundation
import LocaleSupport

extension LanguageCode {
    var name: String {
        Locale.current.localizedString(forLanguageCode: rawValue) ?? rawValue
    }
}
