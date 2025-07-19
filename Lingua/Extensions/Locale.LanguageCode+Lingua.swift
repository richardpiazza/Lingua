import Foundation

extension Locale.LanguageCode {
    var name: String {
        Locale.current.localizedString(forLanguageCode: identifier) ?? identifier
    }
    
    var pickerName: String {
        "\(name) (\(identifier))"
    }
}
