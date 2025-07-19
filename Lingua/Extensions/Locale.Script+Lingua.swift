import Foundation

extension Locale.Script {
    var name: String {
        Locale.current.localizedString(forScriptCode: identifier) ?? identifier
    }
    
    var pickerName: String {
        "\(name) (\(identifier))"
    }
}
