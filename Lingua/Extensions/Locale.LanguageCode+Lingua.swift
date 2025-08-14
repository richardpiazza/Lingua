import Foundation
import LocaleSupport

extension Locale.LanguageCode {
    var name: String {
        if let localizedName {
            "\(localizedName) (\(identifier))"
        } else {
            identifier
        }
    }
}
