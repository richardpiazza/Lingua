import Foundation

extension Locale.Script {
    var name: String {
        if let localizedName {
            "\(localizedName) (\(identifier))"
        } else {
            identifier
        }
    }
}
