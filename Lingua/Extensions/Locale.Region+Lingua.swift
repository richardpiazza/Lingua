import Foundation
import LocaleSupport

extension Locale.Region {
    var name: String {
        if let localizedName {
            "\(localizedName) (\(identifier))"
        } else {
            identifier
        }
    }
}
