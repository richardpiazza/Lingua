import Foundation
import LocaleSupport

extension LanguageCode: @retroactive Identifiable {
    public var id: String { rawValue }
    
    var name: String {
        Locale.current.localizedString(forLanguageCode: rawValue) ?? rawValue
    }
}
