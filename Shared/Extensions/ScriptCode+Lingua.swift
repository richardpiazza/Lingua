import Foundation
import LocaleSupport

extension ScriptCode: Identifiable {
    public var id: String { rawValue }
    
    var name: String {
        Locale.current.localizedString(forScriptCode: rawValue) ?? rawValue
    }
}
