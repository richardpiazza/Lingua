import Foundation
import LocaleSupport

extension ScriptCode {
    var name: String {
        Locale.current.localizedString(forScriptCode: rawValue) ?? rawValue
    }
}
