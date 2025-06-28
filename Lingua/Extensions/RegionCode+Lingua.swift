import Foundation
import LocaleSupport

extension RegionCode {
    var name: String {
        Locale.current.localizedString(forRegionCode: rawValue) ?? rawValue
    }
}
