import Foundation
import LocaleSupport

extension RegionCode: Identifiable {
    public var id: String { rawValue }
    
    var name: String {
        Locale.current.localizedString(forRegionCode: rawValue) ?? rawValue
    }
}
